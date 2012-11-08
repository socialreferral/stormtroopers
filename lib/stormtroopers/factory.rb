require_relative "factory/dummy"

if defined?(Delayed::Job)
  require_relative "factory/delayed_job"
end

module Stormtroopers
  class Factory
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def produce
      raise NotImplementedError.new("produce method not implemented on the factory")
    end
  end
end
