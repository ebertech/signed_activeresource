# -*- encoding: utf-8 -*-
require File.expand_path('../lib/signed_activeresource/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Eberbach"]
  gem.email         = ["andrew@ebertech.ca"]
  gem.description   = %q{A simple gem that lets you hook into an ActiveResource's request to sign the request}
  gem.summary       = %q{Let's users attached an object to "sign" requests as they go out. Useful for plugging in authentication mechanisms.}
  gem.homepage      = "https://github.com/ebertech/signed_activeresource"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "signed_activeresource"
  gem.require_paths = ["lib"]
  gem.version       = SignedActiveResource::VERSION
  
  gem.add_runtime_dependency "activeresource"
end
