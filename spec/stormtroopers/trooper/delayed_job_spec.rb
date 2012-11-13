require "stormtroopers/trooper/delayed_job"

describe Stormtroopers::DelayedJobTrooper do
  let(:job) { stub.as_null_object }
  let(:trooper) { Stormtroopers::DelayedJobTrooper.new(job) }

  describe "#initialize" do
    it "accepts a job and exposes it as #job" do
      job = stub.as_null_object
      trooper = Stormtroopers::DelayedJobTrooper.new(job)
      trooper.job.should equal(job)
    end
  end

  describe "#run" do
    context "a succesful job" do
      it "calls invoke job.invoke_job and then job.destroy" do
        job.should_receive(:invoke_job)
        job.should_receive(:destroy)
        trooper.run
      end
    end

    context "a failing job" do
      it "sets job.last_error and reschedules the job" do
        job.should_receive(:invoke_job) { raise "Oops!" }
        job.should_not_receive(:destroy)
        job.should_receive(:last_error=).with(match("Oops!"))
        trooper.should_receive(:reschedule)
        trooper.run
      end
    end
  end

  describe "#reschedule" do
    context "job has not reached max attempts" do
      it "should reschedule and unlock" do
        job.stub(:attempts).and_return(1)
        job.stub(:max_attempts).and_return(3)
        job.should_receive(:run_at=)
        job.should_receive(:unlock)
        job.should_receive(:save!)
        trooper.reschedule
      end
    end

    context "job has reached max attempts" do
      it "should fail the job" do
        job.stub(:attempts).and_return(3)
        job.stub(:max_attempts).and_return(3)
        job.should_receive(:hook).with(:failure)
        trooper.reschedule
      end
    end
  end
end
