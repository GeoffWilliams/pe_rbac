require 'pe_rbac/role'
require "spec_helper"

describe PeRbac::Role do
  it "returns full list of roles" do

    expect(PeRbac::Role::get_roles).not_to be nil
  end
end
