require "spec_helper"
require "pe_rbac"

describe PeRbac do
  it "has a version number" do
    expect(PeRbac::VERSION).not_to be nil
  end
end
