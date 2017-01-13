require "spec_helper"
require 'pe_rbac/action'
describe PeRbac::Action do
  it "changes the password successfully" do

    expect(PeRbac::Action::change_password('admin', 'cheeseburger')).to be true
  end

  it "obtains the correct token" do
    token = PeRbac::Action::token('admin', 'password')
    expect(token).to eq 'DEADBEEF'
  end

  it "returns false when login unsuccesful" do
    token = PeRbac::Action::token('fred', 'password')
    expect(token).to eq false
  end

  # token
  # login
  # reset_password
end
