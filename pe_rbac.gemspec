# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pe_rbac/version'

Gem::Specification.new do |spec|
  spec.name          = "pe_rbac"
  spec.version       = PeRbac::VERSION
  spec.authors       = ["Geoff Williams"]
  spec.email         = ["geoff@geoffwilliams.me.uk"]

  spec.summary       = %q{Ruby API for Puppet Enterprise RBAC}
  spec.description   = %q{Programatically do stuff with Puppet Enterprise RBAC}
  spec.homepage      = "https://github.com/geoffwilliams/pe_rbac"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "sinatra", "2.0.5"
  spec.add_development_dependency "webrick", "1.4.2"
  spec.add_development_dependency "rack", "2.0.7"
  spec.add_development_dependency "fakefs", "0.20.0"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency  'simplecov', "0.16.1"

  # required at runtime but provided by PE
  spec.add_development_dependency "facter", "2.4.6"


  spec.add_runtime_dependency "excon", "0.62.0"
  spec.add_runtime_dependency "escort", "0.4.0"
  spec.add_runtime_dependency "json_pure", "2.2.0"
end
