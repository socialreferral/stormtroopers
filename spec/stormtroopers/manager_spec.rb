require "stormtroopers/manager"

describe Stormtroopers::Manager do
  let(:manager) { Stormtroopers::Manager.instance }

  before(:each) {
    stub_const("Stormtroopers::Army", Class.new)
  }

  describe "#logger" do
    context "with Rails" do
      it "uses the Rails logger" do
        stub_const("Rails", Class.new)
        logger = stub
        Rails.should_receive(:logger).and_return(logger)
        manager.logger.should equal(logger)
      end
    end

    context "without Rails" do
      it "uses a logger to STDOUT" do
        logger = stub.as_null_object
        Logger.should_receive(:new).with(STDOUT).and_return(logger)
        manager.logger.should equal(logger)
      end
    end
  end

  describe "#config_file" do
    context "with Rails" do
      it "uses a config_file relative to Rails.root" do
        stub_const("Rails", Class.new)
        Rails.should_receive(:root).and_return("/path/to/app")
        manager.config_file.should eq("/path/to/app/config/stormtroopers.yml")
      end
    end

    context "without Rails" do
      it "uses the config_file relative to the current working directory" do
        manager.config_file.should eq(File.join(Dir.getwd, "config", "stormtroopers.yml"))
      end
    end
  end

  describe "#config" do
    it "loads the config_file into a HashWithIndifferentAccess" do
      YAML.should_receive(:load_file).and_return({dummy: "value"})
      manager.config.should eq(HashWithIndifferentAccess.new({dummy: "value"}))
    end
  end

  describe "#armies" do
    it "returns an array of armies matching using #config" do
      army1_config = {factory: {type: :dummy, name: "Trooper 1", sleep_duration: 2}, name: "Dad's Army", max_threads: 1}
      army1 = stub
      Stormtroopers::Army.should_receive(:new).with(HashWithIndifferentAccess.new(army1_config)).and_return(army1)
      army2_config = {factory: {type: :dummy, name: "Trooper 2", sleep_duration: 5}, name: "Mom's Army", max_threads: 2}
      army2 = stub
      Stormtroopers::Army.should_receive(:new).with(HashWithIndifferentAccess.new(army2_config)).and_return(army2)
      config = HashWithIndifferentAccess.new(
        {
          armies: [
            army1_config,
            army2_config,
          ]
        }
      )
      manager.should_receive(:config).and_return(config)
      armies = manager.armies
      manager.armies.size.should eq(2)
      manager.armies.should include(army1)
      manager.armies.should include(army2)
    end
  end

  describe "#manage" do
    let(:army1) { stub(manage: nil, finish: nil) }
    let(:army2) { stub(manage: nil, finish: nil) }

    before(:each) do
      manager.stub(:armies).and_return([army1, army2])
    end

    it "calls manage on each army while managing" do
      manager.stub(:managing?).and_return(false, true, true, false)
      army1.should_receive(:manage).exactly(2).times
      army2.should_receive(:manage).exactly(2).times
      manager.manage
    end

    it "calls finish on each army when no longer managing" do
      manager.stub(:managing?).and_return(false)
      army1.should_receive(:finish)
      army2.should_receive(:finish)
      manager.manage
    end

    it "raises an error when already running" do
      manager.stub(:managing?).and_return(true)
      expect { manager.manage }.to raise_error(Stormtroopers::AlreadyRunning)
    end
  end

  describe ".logger" do
    it "returns the singleton instance's logger" do
      Stormtroopers::Manager.logger.should eq(manager.logger)
    end
  end
end
