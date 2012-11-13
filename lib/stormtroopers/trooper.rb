module Stormtroopers
  class Trooper
    attr_reader :task, :parameters

    def initialize(parameters = {}, &block)
      @parameters = parameters
      @task = block
    end

    def before_run
      # Empty hook for overriding
    end

    def after_run
      # Empty hook for overriding
    end

    def exception(exception)
      # Hook for to override handling exceptions
      raise exception
    end

    def run
      before_run
      task.call
      after_run
    rescue => e
      exception(e)
    end

    def logger
      Manager.logger
    end
  end
end
