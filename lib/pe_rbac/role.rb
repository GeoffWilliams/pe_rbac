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


    # # get the role id for a display name
    # # eg ['Code Deployers', 'blah'] => [4,8]
    # def self.get_role_ids(display_names)
    #   if ! display_names.is_a? Array
    #     display_names = [display_names]
    #   end
    #   roles = get_roles
    #   ids = []
    #   display_names.each { |display_name|
    #     found=get_role_id(display_name)
    #     #if !found
    #     #  raise("RBAC role '#{display_name}' not found")
    #     #end
    #     if found
    #       ids.push(found)
    #     end
    #   }
    #   ids
    # end

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
      role = {
        "permissions"   => permissions,
        "user_ids"      => user_ids,
        "group_ids"     => group_ids,
        "display_name"  => display_name,
        "description"   => description,
      }
      PeRbac::Core::request(:post, '/roles', role)
    end

    def self.update_role(display_name, description=nil, permissions=nil, user_ids=nil, group_ids=nil)
      role_id = get_role_id(display_name)
      if role_id
        role = get_role(role_id)
        role['display_name']  = display_name ? display_name : role['display_name']
        role['description']   = description ? display_name : role['description']
        role['permissions']   = permissions ? permissions : role['permissions']
        role['user_ids']      = user_ids ? user_ids : role['user_ids']
        role['group_ids']     = group_ids ? group_ids : role['group_ids']

        PeRbac::Core::request(:put, "/roles/#{role_id}", role)
      else
        raise("No such role exists: #{display_name} create it first or use ensure_role")
      end
    end
  end
end
