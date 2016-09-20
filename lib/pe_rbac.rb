require "pe_rbac/version"
require 'restclient'
require 'socket'
require 'json'

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

  # get the user id for a login
  # eg 'admin' => '42bf351c-f9ec-40af-84ad-e976fec7f4bd'
  def self.get_user_id(login)
    users = JSON.parse(get_users.body)
    id = nil
    users.each { | user | 
      if user['login'] == login
        id = user['id']
      end
    }
    id
  end

  def self.get_user(id)
    _request(:get, "/users/#{id}")
  end

  def self.create_user(login, email, display_name, password=nil, role_ids=[])
    # completely different to what the PE console sends... :/
    user={
      "login"         => login,
      "email"         => email,
      "display_name"  => display_name,
      "role_ids"      => role_ids,
    }

    if password
      user["password"] = password
    end

    _request(:post, '/users', user)
  end

  def self.update_user(login, email=nil, display_name=nil, role_ids=nil, is_revoked=nil)
    user = JSON.parse(get_user(get_user_id(login)).body)
    if ! user['remote']
      # trade-off for auto id lookup is that you cant change logins...
      user['login'] = login ? login : user['login']
      user['email'] = email ? email : user['email']
      user['display_name'] = display_name ? display_name : user['display_name']
    end
    user['role_ids'] = role_ids ? role_ids : user['role_ids']  
    user['is_revoked'] = (! is_revoked.nil?) ? is_revoked : user['is_revoked'] 

    _request(:put, "/users/#{user['id']}", user)
  end

  def self.change_password(login, new_password)
    token = _request(:post, "/users/#{get_user_id(login)}/password/reset").body

    reset = {
      "token"     => token,
      "password"  => new_password,
    }

    _request(:post, '/auth/reset', reset)
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

  # get the role id for a display name
  # eg 'Code Deployers' => 4
  def self.get_role_id(display_name)
    roles = JSON.parse(get_users.body)
    id = nil
    roles.each { | role |
      if role['displayName'] == display_name
        id = role['id']
      end
    }
    id
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

  #
  # Token
  #
  def self.token(login, password)
    payload = {
      "login"     => login,
      "password"  => password,
    }

    _request(:post, '/auth/token', payload)
  end

  private

  def self._request(method, path, payload=nil, raw=false)
    url = "https://#{CONF[:host]}:#{CONF[:port]}#{BASE_URI}#{path}"
    if payload
      if raw
        _payload=payload
      else
        _payload=payload.to_json
      end
    else
      _payload=nil
    end
    RestClient::Request.execute(
      method: method, 
      url: url,
      ssl_ca_file: CONF[:cacert],
      ssl_client_cert: OpenSSL::X509::Certificate.new(File.read(CONF[:cert])),
      ssl_client_key: OpenSSL::PKey::RSA.new(File.read(CONF[:key])),
      ssl_version: :TLSv1,
      headers: {:content_type => :json, :accept => :json},
      payload: _payload,
    )
  end

end
