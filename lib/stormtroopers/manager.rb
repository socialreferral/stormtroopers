require 'logger'
require 'yaml'
require 'singleton'
require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'
require_relative "./already_running"


if ENV["DJ_SPEED"] == "ludicrous"
  # Go to ludicrous speed (http://www.youtube.com/watch?v=mk7VWcuVOf0) by
  # overriding Delayed::Job#reserve to do the bare minimum to return a job.
  # This will cause all of our workers to pick up jobs from ANY queue, so use
  # with caution!

  class Delayed::Backend::Mongoid::Job
    def self.reserve(worker, max_run_time = Worker.max_run_time)
      where(failed_at: nil, locked_at: nil).find_and_modify({"$set" => {locked_at: db_time_now, locked_by: worker.name}}, new: true)
    end
  end
end


module Stormtroopers
  class Manager
    include Singleton

    def manage
      raise AlreadyRunning if managing?
      @managing = true

      Signal.trap("INT") do
        logger.info "Stopping, waiting for running jobs to complete"
        @managing = false
      end

      logger.info "Starting"
      while managing? do
        assigned = armies.map(&:manage)
        sleep timeout(assigned.include?(true)) 
      end

      armies.each(&:finish)
      logger.info "Stopped, all running jobs completed"
    end

    def managing?
      @managing || false
    end

    def armies
      @armies ||= config[:armies].map do |army_config|
        Army.new(army_config)
      end
    end

    def config
      @config ||= HashWithIndifferentAccess.new(YAML.load_file(config_file))
    end

    def working_directory
      if defined?(Rails)
        Rails.root
      else
        Dir.getwd
      end
    end

    def config_file
      File.join(working_directory, "config", "stormtroopers.yml")
    end

    def logger
      log_directory = File.join(working_directory, "log")
      Dir.mkdir(log_directory) unless File.directory?(log_directory)
      @logger ||= Logger.new(File.join(working_directory, "log", "stormtroopers.log"))
    end

    private

    def timeout(busy)
      @timeout = 0 if @timeout.nil? || busy
      @timeout += 0.1 if @timeout < 2
      @timeout
    end

    class << self
      def logger(*args)
        instance.logger(*args)
      end
    end
  end
end
