require 'pe_rbac/core'

module PeRbac
  module Permission
    #
    # Permissions
    #
    def self.get_permissions()
      resp = PeRbac::Core::request(:get, "/types")
      resp ? JSON.parse(resp.body) : false
    end
  end
end
