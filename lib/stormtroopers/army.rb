module Stormtroopers
  class Army
    attr_reader :factory, :threads, :max_threads, :name

    def initialize(config)
      @name = config[:name] || factory_class(config).name
      @factory = factory_class(config).new(config[:factory])
      @max_threads = config[:max_threads] || 1
      @threads = []
    end

    def factory_class(config)
      @factory_class ||= begin
        raise ArgumentError, "Factory class or type must be defined" if config[:factory][:class].blank? && config[:factory][:type].blank?
        class_name ||= config[:factory].delete(:class)
        class_name ||= "stormtroopers/#{config[:factory].delete(:type)}_factory".camelize
        class_name.constantize
      end
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
                ::Mongoid.session(:default).disconnect
              end
            end
          end
        end
      end
    end

    def finish
      logger.debug("#{name}: Finishing")
      threads.each(&:join)
    end

    def logger
      Stormtroopers::Manager.logger
    end

    private

    def cleanup
      threads.reject!{ |thread| !thread.alive? }
    end
  end
end
