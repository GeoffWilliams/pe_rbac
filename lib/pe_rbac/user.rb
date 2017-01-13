require 'pe_rbac/core'
require 'pe_rbac/action'

module PeRbac
  module User
    def self.get_users
      JSON.parse(PeRbac::Core::request(:get, '/users').body)
    end

    # get the user id for a login or false if missing
    # eg 'admin' => '42bf351c-f9ec-40af-84ad-e976fec7f4bd'
    def self.get_user_id(login)
      users = get_users
      id = false
      i = 0
      while !id and i < users.length do
        if users[i]['login'] == login
          id = users[i]['id']
        end
        i += 1
      end
      id
    end

    def self.get_user(id)
      resp = PeRbac::Core::request(:get, "/users/#{id}")
      resp ? JSON.parse(resp.body) : false
    end

    def self.ensure_user(login, email, display_name, password=nil, role_ids=[])
      if get_user_id(login)
        # existing user
        update_user(login, email, display_name, role_ids)
        if password
          PeRbac::Action::reset_password(login, password)
        end
      else
        # new user
        create_user(login, email, display_name, password, role_ids)
      end

    end

    def self.create_user(login, email, display_name, password=nil, role_ids=[])
      # completely different to what the PE console sends... :/
      # Elegantly convert role_ids to an array if it isn't one already
      user={
        "login"         => login,
        "email"         => email,
        "display_name"  => display_name,
        "role_ids"      => Array(role_ids),
      }

      if password
        user["password"] = password
      end

      PeRbac::Core::request(:post, '/users', user) ? true : false
    end

    def self.update_user(login, email=nil, display_name=nil, role_ids=nil, is_revoked=nil)
      user = get_user(get_user_id(login))
      status = false
      if user
        if ! user['remote']
          # trade-off for auto id lookup is that you cant change logins...
          user['login'] = login ? login : user['login']
          user['email'] = email ? email : user['email']
          user['display_name'] = display_name ? display_name : user['display_name']
        end
        user['role_ids'] = role_ids ? role_ids : user['role_ids']
        user['is_revoked'] = (! is_revoked.nil?) ? is_revoked : user['is_revoked']

        status = PeRbac::Core::request(:put, "/users/#{user['id']}", user) ? true : false
      end
      status
    end
  end
end
