module Stormtroopers
  class Army
    attr_reader :factory, :threads, :max_threads, :name

    def initialize(config)
      @name = config[:name] || factory_class(config).name
      factory_options = HashWithIndifferentAccess.new(config[:factory])
      factory_options[:name] ||= config[:name]
      @factory = factory_class(config).new(factory_options)
      @max_threads = config[:max_threads] || 1
      @threads = []
    end

    def factory_class(config)
      @factory_class ||= self.class.factory_class(config)
    end

    def manage
      assigned = false
      if need_more_troops?
        if trooper = factory.produce
          run_trooper(trooper)
          assigned = true
        end
      end
      assigned
    end

    def need_more_troops?
      cleanup
      threads.count < max_threads
    end

    def run_trooper(trooper)
      threads << Thread.new do
        begin
          trooper.run
        rescue Exception => exception
          logger.error("#{exception.message}:\n#{exception.backtrace.join("\n")}")
          trooper.exception(exception)
        ensure
          if defined?(::Mongoid)
            ::Mongoid::IdentityMap.clear
            ::Mongoid.sessions.keys.each do |session_name|
              ::Mongoid.session(session_name).disconnect
            end
          end
        end
      end
    end

    def finish
      logger.debug("#{name}: Finishing")
      threads.each(&:join)
    end

    def cleanup
      threads.reject!{ |thread| !thread.alive? }
    end

    def logger
      Stormtroopers::Manager.logger
    end

    class << self
      def factory_class(config)
        raise ArgumentError, "Factory class or type must be defined" if config[:factory][:class].blank? && config[:factory][:type].blank?
        class_name ||= config[:factory].delete(:class)
        class_name ||= "stormtroopers/#{config[:factory].delete(:type)}_factory".camelize
        class_name.constantize
      end
    end
  end
end
