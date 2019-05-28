#
# Copyright 2017 Declarative Systems PTY LTD
# Copyright 2016 Puppet Inc.
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
require 'json'
require 'pe_rbac/core'
require 'pe_rbac/action'

module PeRbac
  module Group
    def self.get_groups
      JSON.parse(PeRbac::Core::request(:get, '/groups').body)
    end

    # get the user id for a login or false if missing
    # eg 'admin' => '42bf351c-f9ec-40af-84ad-e976fec7f4bd'
    def self.get_group_id(login)
      groups = get_groups
      id = false
      i = 0
      while !id and i < groups.length do
        if groups[i]['login'] == login
          id = groups[i]['id']
        end
        i += 1
      end
      id
    end

    def self.get_group(id)
      resp = PeRbac::Core::request(:get, "/groups/#{id}")
      resp ? JSON.parse(resp.body) : false
    end

    def self.ensure_group(login, role_ids)
      if get_group_id(login)
        # existing group
        update_group(login, role_ids)
      else
        # new group
        create_group(login, role_ids)
      end

    end

    def self.create_group(login, role_ids=[])
      # completely different to what the PE console sends... :/
      # Elegantly convert role_ids to an array if it isn't one already
      group={
        "login"         => login,
        "role_ids"      => Array(role_ids),
      }

      PeRbac::Core::request(:post, '/groups', group) ? true : false
    end

    def self.update_group(login, role_ids=[])
      group = get_group(get_group_id(login))
      status = false
      if group
        group['login'] = login ? login : group['login']
        group['role_ids'] = role_ids ? Array(role_ids) : group['role_ids']

        status = PeRbac::Core::request(:put, "/groups/#{group['id']}", group) ? true : false
      end
      status
    end

    def self.delete_group(login)
      group = get_group(get_group_id(login))
      status = false
      if group
        PeRbac::Core::request(:delete, "/groups/#{group['id']}") ? true : false
      end
      status
    end
  end
end
