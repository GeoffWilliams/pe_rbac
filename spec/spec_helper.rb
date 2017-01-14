$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
# results in overall error exit status, disable for now
#require 'simplecov'
#SimpleCov.start

require "pe_rbac"
require "pe_rbac/core"
require 'fake_rbac_service'

PeRbac::Core::set_ssldir("./spec/fixtures/ssl")
PeRbac::Core::set_fqdn("localhost")
Thread.start { FakeRbacService::WEBrick.run! }
