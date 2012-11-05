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
      raise
      # Empty hook for overriding
    end

    def run
      before_execution
      task.call
      after_execution
    rescue => e
      exception(e)
    end

    private

    def logger
      Manager.logger
    end
  end
end
