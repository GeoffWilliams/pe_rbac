require "pe_rbac/version"
require 'restclient'
require 'socket'

module PeRbac
  ssldir = '/etc/puppetlabs/puppet/ssl'
  CONF = {
    host: Socket.gethostname,
    port: 4433,
    cert: ssldir + '/certs/pe-internal-orchestrator.pem',
    key: ssldir + '/private_keys/pe-internal-orchestrator.pem',
    cacert: ssldir + '/certs/ca.pem'
  }

  BASE_URI = '/rbac-api/v1'

  #
  # user
  # 

  def self.get_users
    _request(:get, '/users')
  end

  def self.get_user(id)
    _request(:get, "/users/#{id}")
  end

  def self.create_user(display_name, login, email)
    user = {
      "userName"        => nil,
      "displayName"     => display_name,
      "login"           => login,
      "email"           => email,
      "isSuperuser"     => false,
      "isRemote"        => false,
      "isRevoked"       => false,
      "lastLogin"       => nil,
      "roles"           => [],
      "groups"          => [],
      "inheritedRoles"  => [],
    }
    _request(:post, '/users', user)
  end

  def self.update_user(id, login, email, display_name, roles=[], remote=false, superuser=false)
    user = {
      'is_revoked'   => false,
      'id'           => id,
      'login'        => login,
      'email'        => email,
      'display_name' => display_name,
      'role_ids'     => roles,
      'is_remote'    => remote,
      'is_superuser' => superuser,
      #'last_login'   => @property_hash[:last_login],  << WTF puppet... stop smoking bongs
      'is_group'     => false,
    }
    _request(:put, "/users/#{user['id']}", user)
  end

  def self.revoke_user(id, revoke=true)
    user = {
      'is_revoked' => revoke,
      'id'         => id,
    }
    _request(:put, "/users/#{@user['id']}", user)
  end

  #
  # role
  #
  def self.get_roles
    _request(:get, "/roles")
  end

  def self.get_role(id)
    _request(:get, "/roles/#{id}")
  end

  # doesn't seem possible to DELETE roles!
  def self.role(display_name, role_name, description, permissions=[], users=[])
    
    role = {
      "displayName" => display_name,
      "roleName"    => role_name,
      "description" => description,
      "permissions" => permissions,
      "users"       => users,
      "groups"      => [], # doesn't seem to be used yet
    }

    _request(:post, "/roles", role)
  end

  private

  def self._request(method, path, payload = nil)
    url = "https://#{CONF[:host]}:#{CONF[:port]}#{BASE_URI}#{path}"
    RestClient::Request.execute(
      method: method, 
      url: url,
      ssl_ca_file: CONF[:cacert],
      ssl_client_cert: OpenSSL::X509::Certificate.new(File.read(CONF[:cert])),
      ssl_client_key: OpenSSL::PKey::RSA.new(File.read(CONF[:key])),
      ssl_version: :TLSv1,
      payload: payload,
    )
  end


end
