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
        @managing = false
      end

      logger.info "Starting"
      while managing? do
        armies.each(&:manage)
        sleep 0.1
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

    class << self
      def logger(*args)
        instance.logger(*args)
      end
    end
  end
end
