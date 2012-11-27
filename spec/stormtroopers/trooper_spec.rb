require "stormtroopers/trooper"

describe Stormtroopers::Trooper do
  before(:each) do
    stub_const("Stormtroopers::Manager", Class.new)
    logger = stub
    Stormtroopers::Manager.stub(:logger).and_return(logger)
  end

  describe "#initialize" do
    it "it accepts parameters and exposes them through #parameters" do
      parameters = {key1: "value1", key2: "value2"}
      trooper = Stormtroopers::Trooper.new(parameters)
      trooper.parameters.should equal(parameters)
    end

    it "accepts a task block and exposes it through #task" do
      task = lambda { puts "This is a task" }
      trooper = Stormtroopers::Trooper.new({}, &task)
      trooper.task.should equal(task)
    end
  end

  describe "#start" do
    let(:task) { lambda { puts "This is a task" } }
    let(:trooper) { Stormtroopers::Trooper.new({}, &task) }

    it "calls the before_run hook" do
      trooper.should_receive(:before_run)
      trooper.start
    end

    it "calls call on the task" do
      task.should_receive(:call)
      trooper.start
    end

    it "calls the after_run hook" do
      trooper.should_receive(:after_run)
      trooper.start
    end

    it "when the task raises an exception the exception hook is called" do
      task.stub(:call) { raise "Oops" }
      trooper.should_receive(:exception)
      trooper.start
    end
  end

  describe "#logger" do
    it "uses the Stormtroopers::Manager#logger" do
      trooper = Stormtroopers::Trooper.new
      trooper.send(:logger).should equal(Stormtroopers::Manager.logger)
    end
  end
end
