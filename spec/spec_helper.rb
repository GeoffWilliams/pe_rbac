$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "pe_rbac"
require "pe_rbac/core"
require 'fake_rbac_service'
require 'simplecov'

PeRbac::Core::set_ssldir("./spec/fixtures/ssl")
PeRbac::Core::set_fqdn("localhost")
Thread.start { FakeRbacService::WEBrick.run! }
SimpleCov.start
