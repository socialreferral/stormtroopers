module Stormtroopers
  class Manager
    include singleton
    # This class is dependant on rails and active support

    def manage
      armies.each do |army|
        army.manage
      end
    end

    def armies
      @armies ||= config[:armies].map do |army_config|
        Army.new(army_config)
      end
    end

    def config
      @config ||= YAML.load_file("#{Rails.root}/config/config.yml")[RAILS_ENV]
    end

    def logger
      Rails.logger
    end

    class << self
      def logger(*args)
        instance.logger(*args)
      end
    end
  end
end
