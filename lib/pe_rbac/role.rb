#
# Copyright 2016 Geoff Williams for Puppet Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'pe_rbac/core'

module PeRbac
  module Role
    #
    # role
    #
    def self.get_roles
      JSON.parse(PeRbac::Core::request(:get, "/roles").body)
    end

    def self.get_role(id)
      resp = PeRbac::Core::request(:get, "/roles/#{id}")
      resp ? JSON.parse(resp.body) : false
    end

    def self.get_role_id(display_name)
      i=0
      found=false
      roles = get_roles()
      while !found and i < roles.length do
        if roles[i]['display_name'] == display_name
          found = roles[i]['id']
        end
        i+=1
      end
      found
    end

    # CREATE
    def self.ensure_role(display_name, description, permissions=[], user_ids=[])
      if get_role_id(display_name)
        update_role(display_name, description, permissions, user_ids)
      else
        create_role(display_name, description, permissions, user_ids)
      end
    end

    # https://docs.puppet.com/pe/latest/rbac_roles_v1.html#post-roles
    def self.create_role(display_name, description=display_name, permissions=[], user_ids=[], group_ids=[])
      safe_perms = Permission::safe_permissions(permissions)

      role = {
        "permissions"   => safe_perms,
        "user_ids"      => Array(user_ids),
        "group_ids"     => Array(group_ids),
        "display_name"  => display_name,
        "description"   => description,
      }
      PeRbac::Core::request(:post, '/roles', role) ? true : false
    end

    def self.update_role(display_name, description=nil, permissions=nil, user_ids=nil, group_ids=nil)
      role_id = get_role_id(display_name)
      safe_perms = Permission::safe_permissions(permissions)
      status = false
      if role_id
        role = get_role(role_id)
        role['display_name']  = display_name ? display_name : role['display_name']
        role['description']   = description ? display_name : role['description']
        role['permissions']   = safe_perms ? safe_perms : role['permissions']
        role['user_ids']      = user_ids ? Array(user_ids) : role['user_ids']
        role['group_ids']     = group_ids ? Array(group_ids) : role['group_ids']

        PeRbac::Core::request(:put, "/roles/#{role_id}", role)
        status = true
      end
      status
    end

  end
end
