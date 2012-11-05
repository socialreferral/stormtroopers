module Stormtroopers
  class DelayedJobTrooper < Trooper
    attr_reader :job

    def initialize(job)
      @job = job
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
        time ||= job.reschedule_at
        job.run_at = time
        job.unlock
        job.save!
      else
        logger.error "PERMANENTLY removing #{job.name} because of #{job.attempts} consecutive failures.", Logger::INFO
        job.hook(:failure)
      end
    end

    private

    def logger
      Manager.logger
    end
  end
end