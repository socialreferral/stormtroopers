require "stormtroopers"

describe Stormtroopers::Army do
  let(:army) do
    Stormtroopers::Army.new(name: "Dad's Army", max_threads: 2, factory: {name: "Dad's Factory", type: :dummy})
  end

  describe "#initialize" do
    it "extracts the name from the options" do
      army.name.should eq("Dad's Army")
    end

    it "extracts the max_threads from the options" do
      army.max_threads.should eq(2)
    end

    it "instatiates a factory using #factory_class" do
      factory_class = stub
      Stormtroopers::Army.any_instance.should_receive(:factory_class).and_return(factory_class)
      factory_instance = stub
      factory_class.should_receive(:new).with(name: "Dad's Factory", type: :dummy).and_return(factory_instance)
      army.factory.should equal(factory_instance)
    end

    it "when there is no factory name, the army name is used as the factory name" do
      factory_class = stub
      Stormtroopers::Army.any_instance.should_receive(:factory_class).and_return(factory_class)
      factory_instance = stub
      factory_class.should_receive(:new).with(name: "Dad's Army", type: :dummy).and_return(factory_instance)
      army = Stormtroopers::Army.new(name: "Dad's Army", max_threads: 2, factory: {type: :dummy})
      army.factory.should equal(factory_instance)
    end
  end

  describe "#cleanup" do
    it "removes threads that are not alive" do
      live_thread_stub = stub(:alive? => true)
      dead_thread_stub = stub(:alive? => false)
      army.stub(:threads).and_return([live_thread_stub, dead_thread_stub])
      army.cleanup
      army.threads.should eq([live_thread_stub])
    end
  end

  describe "#manage" do
    it "cleans up" do
      army.should_receive(:cleanup)
      army.manage
    end

    it "produces a trooper and runs it if not at max_threads" do
      trooper = stub
      army.factory.should_receive(:produce).and_return(trooper)
      army.should_receive(:run_trooper).with(trooper)
      army.manage
    end

    it "does not produce a trooper if at max_threads" do
      thread_stub = stub(:alive? => true)
      army.stub(:threads).and_return([thread_stub, thread_stub])
      army.factory.should_not_receive(:produce)
      army.manage
    end
  end

  describe "#run_trooper" do
    it "creates a new thread and runs the trooper in it" do
      trooper = mock
      trooper.should_receive(:run)
      Thread.should_receive(:new).and_yield
      army.run_trooper(trooper)
    end

    it "cleans up the Mongoid environment if Mongoid is defined" do
      stub_const("Mongoid", Class.new)
      stub_const("Mongoid::IdentityMap", Class.new)
      Mongoid::IdentityMap.should_receive(:clear)
      mongoid_session = stub
      Mongoid.should_receive(:session).with(:default).and_return(mongoid_session)
      mongoid_session.should_receive(:disconnect)
      trooper = mock
      trooper.should_receive(:run)
      Thread.should_receive(:new).and_yield
      army.run_trooper(trooper)
    end
  end

  describe "#finish" do
    it "calls join on all threads" do
      thread1 = stub
      thread1.should_receive(:join)
      thread2 = stub
      thread2.should_receive(:join)
      army.stub(:threads).and_return([thread1, thread2])
      army.finish
    end
  end

  describe "#logger" do
    it "takes the logger from Stormtroopers::Manager" do
      logger = stub
      Stormtroopers::Manager.stub(:logger).and_return(logger)
      army.logger.should equal(logger)
    end
  end

  describe ".factory_class" do
    it "returns the class specified in the options" do
      stub_const("MyFactory", Class.new)
      Stormtroopers::Army.factory_class(factory: {class: "MyFactory"}).should equal(MyFactory)
    end

    it "returns a builtin factory class when type is specified in the options" do
      Stormtroopers::Army.factory_class(factory: {type: :dummy}).should equal(Stormtroopers::DummyFactory)
      Stormtroopers::Army.factory_class(factory: {type: :delayed_job}).should equal(Stormtroopers::DelayedJobFactory)
    end

    it "raises an ArgumentError when no type or class is specified" do
      expect { Stormtroopers::Army.factory_class(factory: {}) }.to raise_error(ArgumentError)
    end
  end
end
