require "stormtroopers/factory"

describe Stormtroopers::Factory do
  describe "#options" do
    it "exposes the options passed in during #initialize" do
      options = {key1: "value1", key2: "value2"}
      factory = Stormtroopers::Factory.new(options)
      factory.options.should equal(options)
    end
  end

  describe "#produce" do
    it "is not implemented" do
      factory = Stormtroopers::Factory.new
      expect { factory.produce }.to raise_error(NotImplementedError)
    end
  end

  describe "#logger" do
    it "uses the Stormtroopers::Manager#logger" do
      stub_const("Stormtroopers::Manager", Class.new)
      logger = stub
      Stormtroopers::Manager.stub(:logger).and_return(logger)
      factory = Stormtroopers::Factory.new
      factory.logger.should equal(logger)
    end
  end
end
