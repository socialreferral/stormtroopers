module Stormtroopers
  class DelayedJobFactory < Factory
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def produce
      worker = Struct.new(name: "Stormtroopers")
      if job = Delayed::Job.reserve(worker)
        DelayedJobTrooper.new(job)
      end
    end
  end
end