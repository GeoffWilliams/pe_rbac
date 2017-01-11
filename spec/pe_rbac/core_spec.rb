require 'pe_rbac/core'
require "spec_helper"

describe PeRbac::Core do
  it "get_conf returns a hash" do

    expect(PeRbac::Core::get_conf).not_to be nil
  end
end
