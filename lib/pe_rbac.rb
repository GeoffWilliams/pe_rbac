require "pe_rbac/version"
require 'restclient'
require 'yaml'

module PeRbac
  CONFIGFILE = "#{Puppet.settings[:confdir]}/classifier.yaml"

  # This is autoloaded by the master, so rescue the permission exception.
  CONF = YAML.load_file(CONFIGFILE)
  BASE_URI = '/rbac-api/v1'

  #
  # user
  # 

  def get_users
    _request(:get, '/users')
  end

  def get_user(id)
    _request(:get, "/users/#{id}")
  end

  def create_user
    user = {
      "userName"        => nil,
      "displayName"     => "aaa",
      "login"           => "bbbb",
      "email"           => "",
      "isSuperuser"     => false,
      "isRemote"        => false,
      "isRevoked"       => false,
      "lastLogin"       => null,
      "roles"           => [],
      "groups"          => [],
      "inheritedRoles"  => [],
    }
    _request(:post, '/users', user)
  end

  def update_user(id, login, email, display_name, roles=[], remote=false, superuser=false,
    user = {
      'is_revoked'   => revoked?,
      'id'           => id,
      'login'        => login,
      'email'        => email,
      'display_name' => display_name,
      'role_ids'     => roles),
      'is_remote'    => remote,
      'is_superuser' => superuser,
      #'last_login'   => @property_hash[:last_login],  << WTF puppet... stop smoking bongs
      'is_group'     => false,
    }

    _request(:put, "/users/#{user['id']}", user)
  end

  def revoke_user(id, revoke=true)
    user = {
      'is_revoked' => revoke,
      'id'         => id,
    }
    _request(:put, "/users/#{@user['id']}", user)
  end

  #
  # role
  #
  def get_roles
    _request(:get, "/roles")
  end

  def get_role(id)
    _request(:get, "/roles/#{id}")
  end

  # doesn't seem possible to DELETE roles!
  def role(display_name, role_name, description, permissions=[], users=[])
    
    role = {
      "displayName" => display_name,
      "roleName"    => role_name,
      "description" => description,
      "permissions" => permissions,
      "users":      => users,
      "groups"      => [], # doesn't seem to be used yet
    }

    _request(:post, "/roles", role)
  end

  private

  def _request(method, path, payload = nil)
    url = "https://#{CONF['server']}:#{CONF['port']}#{BASE_URI}#{path}"
    RestClient::Request.execute(
      method: method, 
      url: url,
      ssl_ca_file: Puppet.settings[:localcacert],
      ssl_client_cert: OpenSSL::X509::Certificate.new(File.read(Puppet.settings[:hostcert])),
      ssl_client_key: OpenSSL::PKey::RSA.new(File.read(Puppet.settings[:hostprivkey])),
      ssl_version: :TLSv1,
      payload: payload,
    )
  end


end
