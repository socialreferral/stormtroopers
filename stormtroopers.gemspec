# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stormtroopers/version'

Gem::Specification.new do |gem|
  gem.name          = "stormtroopers"
  gem.version       = Stormtroopers::VERSION
  gem.authors       = ["Andre Meij", "Mark Kremer"]
  gem.email         = ["andre@socialreferral.com"]
  gem.description   = %q{Stormtroopers is a jruby execution environment for delayed jobs }
  gem.summary       = %q{Execute delayed jobs in a threaded jruby environment}
  gem.homepage      = "http://github.com/socialreferral/stormtroopers"

  gem.add_dependency('activesupport', '>= 3.2.0')

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
