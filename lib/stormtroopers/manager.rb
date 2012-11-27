require 'logger'
require 'yaml'
require 'singleton'
require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'
require_relative "./already_running"


module Stormtroopers
  class Manager
    include Singleton

    def manage
      raise AlreadyRunning if managing?
      @managing = true

      Signal.trap("INT") do
        logger.info "Stopping, waiting for running jobs to complete"
        log_current_status
        @managing = false
      end

      Signal.trap("USR2") do
        log_current_status
      end

      logger.info "Starting"

      if config[:speed] == "ludicrous"
        logger.info "Ludicrous speed? Sir! we have never gone that fast before, I dont know if the ship can take it! Whats the matter Colonel Sanders? CHICKEN?!"
        puts "Ludicrous speed? Sir! we have never gone that fast before, I dont know if the ship can take it! Whats the matter Colonel Sanders? CHICKEN?!"
        Delayed::Backend::Mongoid::Job.class_eval do
          def self.reserve(worker, max_run_time = Delayed::Worker.max_run_time)
            where(failed_at: nil, locked_at: nil).find_and_modify({"$set" => {locked_at: db_time_now, locked_by: worker.name}}, new: true)
          end
        end
      end

      while managing? do
        assigned = armies.map(&:manage)
        sleep timeout(assigned.include?(true)) 
      end

      armies.each(&:finish)
      logger.info "Stopped, all running jobs completed"
    end

    def log_current_status
      logger.info "Current status"
      armies.each do |army|
        army.running_troopers_status.each do |status|
          logger.info "#{army.name}: #{status}"
        end
      end
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
      unless @logger 
        log_directory = File.join(working_directory, "log")
        Dir.mkdir(log_directory) unless File.directory?(log_directory)
        @logger = Logger.new(File.join(working_directory, "log", "stormtroopers.log"), 'daily')
        logger.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime.strftime("%Y-%m-%d %H:%M:%S")} #{severity}: #{msg}\n"
        end
      end
      @logger
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
