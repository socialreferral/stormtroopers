module Stormtroopers
  class Trooper
    attr_reader :task, :parameters, :started_at

    def initialize(parameters = {}, &block)
      @parameters = parameters
      @task = block
    end

    def name
      # Override with a useful name here for logging purposes
      @task.to_s
    end

    def status
      "#{name} running since #{started_at.strftime("%Y-%m-%d %H:%M:%S")} (#{(Time.now - started_at).to_i} seconds)" if started_at
    end

    def before_run
      # Empty hook for overriding
    end

    def after_run
      # Empty hook for overriding
    end

    def exception(exception)
      # Hook for to override handling exceptions
      logger.error "Error processing #{task_name}: #{exception.message}"
      logger.debug "Stacktrace #{task_name}:\n#{exception.backtrace.join("\n")}"
      raise exception
    end

    def run
      task.call
    end

    def start
      @started_at = Time.now
      before_run
      run
      after_run
    rescue => e
      exception(e)
    end

    private

    def logger
      Manager.logger
    end
  end
end
