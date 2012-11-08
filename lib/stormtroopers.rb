require_relative "./stormtroopers/version"
require_relative "./stormtroopers/trooper"
require_relative "./stormtroopers/manager"
require_relative "./stormtroopers/factory"
require_relative "./stormtroopers/army"

Dir["#{File.dirname(__FILE__)}/stormtroopers/factory/*.rb"].each{ |f| require f }
Dir["#{File.dirname(__FILE__)}/stormtroopers/trooper/*.rb"].each{ |f| require f }
