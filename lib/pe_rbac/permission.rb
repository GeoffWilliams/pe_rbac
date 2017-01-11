require 'pe_rbac/core'

module PeRbac
  module Permission
    #
    # Permissions
    #
    def self.get_permissions()
      PeRbac::Core::request(:get, "/types")
    end
  end
end
