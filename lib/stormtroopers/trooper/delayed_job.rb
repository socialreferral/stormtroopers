module Stormtroopers
  class DelayedJobTrooper < Trooper
    attr_reader :job

    def initialize(job)
      @job = job
    end

    def task_name
      "#{@job.name} (#{job.id})"
    end

    def run
      job.invoke_job
      job.destroy
    rescue => error
      job.last_error = "#{error.message}\n#{error.backtrace.join("\n")}"
      logger.info "#{job.name} failed with #{error.class.name}: #{error.message} - #{job.attempts} failed attempts"
      reschedule
    end

    def reschedule
      if (job.attempts += 1) < max_attempts(job)
        job.run_at = job.reschedule_at
        job.unlock
        job.save!
      else
        logger.error("PERMANENTLY removing #{job.name} (#{job.id}) because of #{job.attempts} consecutive failures.")
        job.hook(:failure)
        job.fail!
      end
    end

    def max_attempts(job)
      job.max_attempts || Delayed::Worker.max_attempts
    end
  end
end
