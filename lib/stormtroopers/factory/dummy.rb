module Stormtroopers
  class DummyFactory < Factory

    def produce
      DummyTrooper.new(options)
    end
  end
end
