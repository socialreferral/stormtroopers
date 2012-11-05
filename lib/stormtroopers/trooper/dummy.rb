module Stormtroopers
  class DummyTrooper < Trooper

    def run
      logger.debug "#{name}: Dummy job started, sleeping for #{sleep_duration}"
      sleep(sleep_duration)
      logger.debug "#{name}: Dummy job completed, w00t"
    end

    private

    def name
      parameters[:name] || 'noname'
    end

    def sleep_duration
      parameters[:sleep_duration] || 1
    end
  end
end