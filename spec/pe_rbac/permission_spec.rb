require 'pe_rbac/permission'
require "spec_helper"

describe PeRbac::Permission do
  it "returns full list of permissions" do
    permissions = PeRbac::Permission::get_permissions
    expect(permissions.class).to be Array
    expect(permissions.size).to eq 12
  end

  it "removes invalid permissions" do
    want_perms = [
      {
        "object_type" => "tokens",
        "action"      => "override_lifetime",
        "instance"    => "*",
      },
      {
        "object_type" => "tokens",
        "action"      => "invalid",
        "instance"    => "*",
      }
    ]
    safe_perms = PeRbac::Permission::safe_permissions(want_perms)

    expect(safe_perms.size).to be 1
    expect(safe_perms[0]["object_type"]).to eq "tokens"
    expect(safe_perms[0]["action"]).to eq "override_lifetime"
    expect(safe_perms[0]["instance"]).to eq "*"

  end
end
