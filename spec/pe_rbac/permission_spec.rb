require 'pe_rbac/permission'
require "spec_helper"

describe PeRbac::Permission do
  it "returns full list of permissions" do
    permissions = PeRbac::Permission::get_permissions
    expect(permissions.class).to be Array
    expect(permissions.size).to eq 12
  end
end
