require 'pe_rbac/role'
require "spec_helper"

describe PeRbac::Role do
  it "returns full list of roles" do
    expect(PeRbac::Role::get_roles).not_to be nil
    expect(PeRbac::Role::get_roles.size).to eq 4
  end

  it "returns a specific role" do
    role = PeRbac::Role::get_role(2)

    expect(role).not_to eq false
    expect(role['display_name']).to eq 'Operators'
  end

  it "returns a false if looking up non-existant role" do
    role = PeRbac::Role::get_role(99)

    expect(role).to be false
  end

  it "looks up role ids from display names correctly" do
    rid = PeRbac::Role::get_role_id("Operators")
    expect(rid).to eq 2
  end

  it "returns false when looking up non-existant role ids" do
    rid = PeRbac::Role::get_role_id("not_here")
    expect(rid).to eq false
  end

  it "creates new role correctly" do
    result = PeRbac::Role::create_role(
      'display_name',
      'description',
    )
    expect(result).to be true
  end

  it "updates existing role correctly" do
    result = PeRbac::Role::update_role(
      'Operators',
      'description',
    )
    expect(result).to be true
  end

  it "returns false when updating non-existant role" do
    result = PeRbac::Role::update_role(
      'not_here',
      'description',
    )
    expect(result).to be false
  end

  it "ensures roles are in desired state correctly" do
    result = PeRbac::Role::ensure_role('Operators', 'admin')
    expect(result).to be true

    result = PeRbac::Role::ensure_role('not_here', 'not_here')
    expect(result).to be true
  end
end
