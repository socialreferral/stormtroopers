module Stormtroopers
  class DelayedJobFactory < Factory
    def produce
      worker = Delayed::Worker.new(options)
      worker.name = "rand #{Time.now.utc.to_f} #{rand(1000)}"
      if job = Delayed::Job.reserve(worker)
        logger.info("#{self.name} producing trooper to run #{job.queue} job #{job.id}")
        DelayedJobTrooper.new(job)
      end
    end
  end
end
