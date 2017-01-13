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

  it "returns false looking up non-existant user by id" do
    user = PeRbac::User::get_user('xxxxxxxx')

    # check we got a response the same size as the one in our json file
    expect(user).to be false
  end

  it "returns the correct ID for given user" do
    uid = PeRbac::User::get_user_id('admin')

    expect(uid).to eq '42bf351c-f9ec-40af-84ad-e976fec7f4bd'
  end

  it "returns false for non existant user" do
    uid = PeRbac::User::get_user_id('not_here')

    expect(uid).to eq false
  end

  # create_user
  it "creates a normal user correctly" do
    result = PeRbac::User::create_user(
      'login',
      'email',
      'display_name',
      'password',
      4
    )
    expect(result).to be true
  end

  # update_user
  it "updates an existing user correctly" do
    result = PeRbac::User::update_user(
      'admin',
      'emailA',
      'display_nameA',
      5,
    )
    expect(result).to be true
  end

  it "returns false attempting to update non-existant user" do
    result = PeRbac::User::update_user(
      'not_here',
      'email',
      'display_name',
      5,
    )
    expect(result).to be false
  end

  # ensure_user
  it "ensures users are in desired state correctly" do
    # existing user - should indicate success
    result = PeRbac::User::ensure_user(
      'admin',
      'email',
      'display_name',
      'password',
      4
    )
    expect(result).to be true

    # new user - should indicate success
    result = PeRbac::User::ensure_user(
      'not_here',
      'email',
      'display_name',
      'password',
      4
    )
    expect(result).to be true
  end

end
