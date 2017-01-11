require 'pe_rbac/user'
require "fake_rbac_service"
require "spec_helper"

# before do
# #   FakeRbacService::WEBrick.run!
#   PeRbac::Core::set_ssldir("./spec/fixtures/ssl")
#   PeRbac::Core::set_fqdn("localhost")
# end

describe PeRbac::User do
  it "returns full list of users" do

    expect(PeRbac::User::get_users).not_to be nil
  end
end
