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

  it "merge permissions merges correctly" do
    perms = [
      {
        'object_type' => 'foo',
        'action'      => 'bar',
        'instance'    => 'baz',
      },
      {
        'object_type' => 'curly',
        'action'      => 'larry',
        'instance'    => 'moe',
      },
    ]

    new_perms = [
      {
        'object_type' => 'new_object_type',
        'action'      => 'new_action',
        'instance'    => 'new_instance',
      }
    ]

    # merge a single new object
    merged = PeRbac::Core::merge_permissions(perms, new_perms)
    expect(merged).not_to be nil
    expect(merged.size).to be 3
    expect(merged[2]['object_type']).to eq 'new_object_type'
  end

  it "merges existing permissions correctly" do
    perms = [
      {
        'object_type' => 'foo',
        'action'      => 'bar',
        'instance'    => 'baz',
      },
      {
        'object_type' => 'curly',
        'action'      => 'larry',
        'instance'    => 'moe',
      },
    ]

    new_perms = [
      {
        'object_type' => 'curly',
        'action'      => 'larry',
        'instance'    => 'moe',
      }
    ]

    merged = PeRbac::Core::merge_permissions(perms, new_perms)
    expect(merged).not_to be nil
    expect(merged.size).to be 2
  end
end
