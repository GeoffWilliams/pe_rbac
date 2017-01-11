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
    users = PeRbac::User::get_users

    # check we got a response the same size as the one in our json file
    expect(users).not_to be nil
    expect(users.size).to be 3
  end

  it "returns a specific user" do
    user = PeRbac::User::get_user('af94921f-bd76-4b58-b5ce-e17c029a2790')

    # check we got a response the same size as the one in our json file
    expect(user).not_to be nil
    expect(user['login']).to eq'api_user'
  end
end
