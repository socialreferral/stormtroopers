module Stormtroopers
  class Army
    attr_reader :factory, :threads, :max_threads

    def initialize(config)
      @factory = factory_class(config).new(config[:factory])
      @max_threads = config[:max_threads] || 1
      @threads = []
    end

    def factory_class(config)
      raise ArgumentError, "Factory class or type must be defined" if config[:factory][:class].blank? && config[:factory][:type].blank?
      class_name ||= config[:factory].delete(:class)
      class_name ||= "stormtroopers/#{config[:factory].delete(:type)}_factory".camelize
      class_name.constantize
    end

    def manage
      cleanup
      if threads.count < max_threads
        if trooper = factory.produce
          threads << Thread.new do
            begin
              trooper.run
            ensure
              if defined?(::Mongoid)
                ::Mongoid::IdentityMap.clear
                ::Mongoid.disconnect_sessions
              end
            end
          end
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
