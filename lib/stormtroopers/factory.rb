module Stormtroopers
  class Factory
    attr_reader :options, :name

    def initialize(options = {})
      @options = options
      @name = options[:name]
    end

    def produce
      raise NotImplementedError.new("produce method not implemented on the factory")
    end

    def logger
      Manager.logger
    end
  end
end
