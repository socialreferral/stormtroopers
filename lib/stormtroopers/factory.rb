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

require_relative "factory/dummy"

if defined?(Delayed::Job)
  require_relative "factory/delayed_job"
end

