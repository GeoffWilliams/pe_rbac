require "spec_helper"
require 'pe_rbac/action'
require 'fakefs/safe'
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

  it "creates token file for logged in user" do

    # use a fakefs to avoid overwriting real files on the system, we have to
    # also clone our fake SSL certs as well
    config = File.expand_path('./spec')
    FakeFS::FileSystem.clone(config, '/spec')
    FakeFS do
      # create a fake homedir on our fakefs to hold the fake token :)
      FileUtils.mkdir_p Dir.home

      PeRbac::Action::login('admin', 'password')

      token = File.read(File.join(Dir.home, '/.puppetlabs', '/token'))
      expect(token).to eq 'DEADBEEF'
    end

  end
  # token
  # login
  # reset_password
end
