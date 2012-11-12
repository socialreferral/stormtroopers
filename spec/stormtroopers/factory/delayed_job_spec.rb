require "stormtroopers/factory/delayed_job"

describe Stormtroopers::DelayedJobFactory do
  let(:factory) { Stormtroopers::DelayedJobFactory.new }
  let(:worker) { stub }

  before(:each) do
    stub_const("Delayed::Worker", Class.new)
    Delayed::Worker.stub(:new).and_return(worker)
    worker.stub(:name=).and_return(nil)
    worker.stub(:name).and_return(nil)
    stub_const("Delayed::Job", Class.new)
    Delayed::Job.stub(:reserve)
  end

  describe "#produce" do
    it "instantiates a new worker" do
      Delayed::Worker.should_receive(:new).and_return(worker)
      factory.produce
    end

    it "assigns the worker a name with random value" do
      Time.stub_chain(:now, :utc, :to_f).and_return("1234")
      factory.should_receive(:rand).and_return(500)
      worker.should_receive(:name=).with("rand 1234 500")
      factory.produce
    end

    it "reserves a job and instantiates a trooper" do
      job = stub.as_null_object
      trooper = stub
      Delayed::Job.should_receive(:reserve).and_return(job)
      Stormtroopers::DelayedJobTrooper.should_receive(:new).and_return(trooper)
      factory.produce.should equal(trooper)
    end

    it "does not instantiate a trooper if it doesn't find a job to reserve" do
      Delayed::Job.should_receive(:reserve).and_return(nil)
      factory.produce.should be_nil
    end
  end
end
