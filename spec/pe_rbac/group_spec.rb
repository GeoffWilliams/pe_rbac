require 'pe_rbac/group'
require "fake_rbac_service"
require "spec_helper"

# before do
# #   FakeRbacService::WEBrick.run!
#   PeRbac::Core::set_ssldir("./spec/fixtures/ssl")
#   PeRbac::Core::set_fqdn("localhost")
# end

describe PeRbac::Group do
  it "returns full list of groups" do
    groups = PeRbac::Group::get_groups

    # check we got a response the same size as the one in our json file
    expect(groups).not_to be nil
    expect(groups.size).to be 2
  end

  it "returns a specific group" do
    group = PeRbac::Group::get_group('df374820-9a78-46e3-85ee-726793923f23')

    # check we got a response the same size as the one in our json file
    expect(group).not_to be nil
    expect(group['login']).to eq'test_group'
  end

  it "returns false looking up non-existent group by id" do
    group = PeRbac::Group::get_group('xxxxxxxx')

    # check we got a response the same size as the one in our json file
    expect(group).to be false
  end

  it "returns the correct ID for given group" do
    uid = PeRbac::Group::get_group_id('admins')

    expect(uid).to eq '9cfb0f32-df90-4900-8212-ed2b31a4340c'
  end

  it "returns false for non existent group" do
    uid = PeRbac::Group::get_group_id('not_here')

    expect(uid).to eq false
  end

  # create_group
  it "creates a normal group correctly" do
    result = PeRbac::Group::create_group(
      'login',
      4
    )
    expect(result).to be true
  end

  # update_group
  it "updates an existing group correctly" do
    result = PeRbac::Group::update_group(
      'admins',
      5,
    )
    expect(result).to be true
  end

  it "returns false attempting to update non-existent group" do
    result = PeRbac::Group::update_group(
      'not_here',
      5,
    )
    expect(result).to be false
  end

  # ensure_group
  it "ensures groups are in desired state correctly" do
    # existing group - should indicate success
    result = PeRbac::Group::ensure_group(
      'admins',
      4
    )
    expect(result).to be true

    # new group - should indicate success
    result = PeRbac::Group::ensure_group(
      'not_here',
      4
    )
    expect(result).to be true
  end

end
