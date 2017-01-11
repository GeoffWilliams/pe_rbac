$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "pe_rbac"
require "pe_rbac/core"
PeRbac::Core::set_ssldir("./spec/fixtures/ssl")
PeRbac::Core::set_fqdn("localhost")
