require 'logger'
require 'yaml'
require 'singleton'
require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'

module Stormtroopers
  class Manager
    include Singleton
    # This class is dependant on rails and active support

    def manage
      logger.info "Starting"
      loop do
        armies.each(&:manage)
        sleep 0.1
      end
    rescue Interrupt => e
      logger.info "Stopping, waiting for running jobs to complete"
      armies.each(&:finish)
      logger.info "Stopped, all running jobs completed"
    end

    def armies
      @armies ||= config[:armies].map do |army_config|
        Army.new(army_config)
      end
    end

    def config
      @config ||= HashWithIndifferentAccess.new(YAML.load_file(config_file))
    end

    def config_file
      if defined?(Rails)
        "#{Rails.root}/config/stormtroopers.yml"
      else
        "#{File.expand_path('../../../config', __FILE__)}/stormtroopers.yml"
      end
    end

    def logger
      if defined?(Rails)
        Rails.logger
      else
        @logger ||= Logger.new(STDOUT)
      end
    end

    private

    class << self
      def logger(*args)
        instance.logger(*args)
      end
    end
  end
end
