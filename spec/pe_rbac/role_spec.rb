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


  # def self.ensure_role(display_name, description, permissions=[], user_ids=[])
  # def self.create_role(display_name, description=display_name, permissions=[], user_ids=[], group_ids=[])
  # def self.update_role(display_name, description=nil, permissions=nil, user_ids=nil, group_ids=nil)
  #

end
