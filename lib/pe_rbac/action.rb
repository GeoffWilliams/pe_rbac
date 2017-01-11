require 'pe_rbac/core'
require 'pe_rbac/user'
module PeRbac
  module Action
    def self.change_password(login, new_password)
      token = PeRbac::Core::request(:post, "/users/#{User::get_user_id(login)}/password/reset").body

      reset = {
        "token"     => token,
        "password"  => new_password,
      }

      PeRbac::Core::request(:post, '/auth/reset', reset)
    end

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

      JSON.parse(PeRbac::Core::request(:post, '/auth/token', payload))['token']
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
      if user_id
        # get password reset token
        reset_token = PeRbac::Core::request(:post, "/users/#{user_id}/password/reset")

        # reset password
        PeRbac::Core::request(:post, '/auth/reset', {
          'token'     => reset_token,
          'password'  => password,
        })
      else
        Escort::Logger.error.error "No such user: #{login}"
      end
    end


  end
end