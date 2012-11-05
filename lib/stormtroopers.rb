require "stormtroopers/version"
require "stormtroopers/trooper"
require "stormtroopers/manager"
require "stormtroopers/factory"
require "stormtroopers/army"

Dir['./lib/stormtroopers/factory/*.rb'].each{ |f| require f }
Dir['./lib/stormtroopers/trooper/*.rb'].each{ |f| require f }

module Stormtroopers

end
