require_relative "./stormtroopers/version"
require_relative "./stormtroopers/trooper"
require_relative "./stormtroopers/manager"
require_relative "./stormtroopers/factory"
require_relative "./stormtroopers/army"

Dir['./lib/stormtroopers/factory/*.rb'].each{ |f| require f }
Dir['./lib/stormtroopers/trooper/*.rb'].each{ |f| require f }

module Stormtroopers

end
