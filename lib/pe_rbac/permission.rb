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
  module Permission
    #
    # Permissions
    #
    def self.get_permissions()
      resp = PeRbac::Core::request(:get, "/types")
      resp ? JSON.parse(resp.body) : false
    end

    # Not all requested permissions may be avaiable per use (change between
    # versions).  To mitigate this, requeste the list of all valid permissions
    # and remove any permissions that are not in the list from the final list of
    # permissions to request
    def self.safe_permissions(want_perms)
      safe_perms  = []
      valid_perms = Permission::get_permissions()

      want_perms.each { |wp|
        valid = false
        valid_perms.each { |vp|
          if  wp['object_type'] == vp['object_type']
            vp['actions'].each { |va|
              # scan for valid action inside object permissions
              if wp['action'] == va['name']
                valid = true
              end
            }
          end
        }
        if valid
          safe_perms << wp
        end
      }

      safe_perms
    end
  end
end
