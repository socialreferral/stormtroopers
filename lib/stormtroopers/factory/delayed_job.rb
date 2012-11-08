require_relative "../troopers/delayed_job"

module Stormtroopers
  class DelayedJobFactory < Factory
    def produce
      worker = Struct.new(name: "Stormtroopers")
      if job = Delayed::Job.reserve(worker)
        DelayedJobTrooper.new(job)
      end
    end
  end
end
