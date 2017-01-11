require 'pe_rbac/permission'
require "spec_helper"

describe PeRbac::Permission do
  it "returns full list of roles" do

    expect(PeRbac::Permission::get_permissions).not_to be nil
  end
end
