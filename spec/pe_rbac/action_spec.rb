require "spec_helper"
require 'pe_rbac/action'
describe PeRbac::Action do
  it "changes the password successfully" do

    expect(PeRbac::Action::change_password('admin', 'cheeseburger')).to be true
  end
end
