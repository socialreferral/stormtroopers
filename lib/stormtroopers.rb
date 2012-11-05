require "stormtroopers/version"
require "stormtroopers/worker"
require "stormtroopers/manager"

Dir['./stormtroopers/factory/*.rb'].each{ |f| require f }
Dir['./stormtroopers/trooper/*.rb'].each{ |f| require f }

module Stormtroopers

end
