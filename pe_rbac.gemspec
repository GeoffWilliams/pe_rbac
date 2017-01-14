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
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "sinatra", "1.4.7"
  spec.add_development_dependency "webrick", "1.3.1"
  spec.add_development_dependency "rack", "1.6.5"
  spec.add_development_dependency "fakefs", "0.10.1"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency  'simplecov', "0.12.0"

  spec.add_runtime_dependency "rest-client", "2.0.0"
  spec.add_runtime_dependency "escort", "0.4.0"
  spec.add_runtime_dependency "facter", "2.4.6"
end
