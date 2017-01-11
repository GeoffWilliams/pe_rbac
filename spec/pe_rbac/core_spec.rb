require 'pe_rbac/core'
require "spec_helper"
# https://www.fedux.org/articles/2015/08/02/setting-up-a-ruby-based-http-server-to-back-your-test-suite.html
# before :all do
#   @web_server = Process.spawn(
#     'script/http_server.rb',
#     in: :close,
#     out: 'tmp/httpd-out.log',
#     err: 'tmp/httpd-err.log'
#   )
#
#   sleep 1
# end
describe PeRbac::Core do
  it "get_conf returns a hash" do

    expect(PeRbac::Core::get_conf).not_to be nil
  end
end
