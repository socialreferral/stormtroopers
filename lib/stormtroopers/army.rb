module Stormtroopers
  class Army
    attr_reader :factory, :threads, :max_threads

    def initialize(config)
      @factory = "stormtroopers/#{config[:factory].delete(:type)}_factory".camelize.constantize.new(config[:factory])
      @max_threads = config[:max_threads] || 1
      @threads = []
    end

    def manage
      cleanup
      if threads.count < max_threads
        if trooper = factory.produce
          threads << Thread.new { trooper.run }
        end
      end
    end

    def finish
      threads.each(&:join)
    end

    private

    def cleanup
      threads.reject!{ |thread| !thread.alive? }
    end
  end
end