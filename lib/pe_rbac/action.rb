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
require 'pe_rbac/user'
require 'pe_rbac/permissions'

module PeRbac
  module Action

    #
    # Token
    #
    def self.token(login, password, lifetime=false)
      payload = {
        "login"     => login,
        "password"  => password,
      }

      # see https://docs.puppet.com/pe/latest/rbac_token_auth.html#setting-a-token-specific-lifetime
      if lifetime
        payload["lifetime"] = lifetime
      end
      resp = PeRbac::Core::request(:post, '/auth/token', payload)
      resp ? JSON.parse(resp.body)['token'] : false
    end

    def self.login(login, password, lifetime=false)
      dirname = Dir.home + '/.puppetlabs'
      tokenfile = dirname + '/token'
      if ! Dir.exist?(dirname)
        Dir.mkdir(dirname, 0700)
      end
      File.write(tokenfile, token(login, password, lifetime))
      File.chmod(0600, tokenfile)
    end

    def self.reset_password(login, password)
      # lookup user id
      user_id = User::get_user_id(login)
      status = false
      if user_id
        # get password reset token
        reset_token = PeRbac::Core::request(:post, "/users/#{user_id}/password/reset")

        # reset password
        PeRbac::Core::request(:post, '/auth/reset', {
          'token'     => reset_token,
          'password'  => password,
        })
        status = true
      end
      status
    end

    def self.show_permissions
      resp = PeRbac::Permission::get_permissions
      puts resp.to_s
    end

  end
end
