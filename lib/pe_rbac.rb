require "pe_rbac/version"
require 'restclient'
require 'socket'
require 'json'

module PeRbac
  ssldir = '/etc/puppetlabs/puppet/ssl'
  fqdn = %x(facter fqdn).strip.downcase
  pe_old_pk   = "#{ssldir}/private_keys/pe-internal-orchestrator.pem"
  pe_old_cert = "#{ssldir}/certs/pe-internal-orchestrator.pem"
  pe_new_pk   = "#{ssldir}/private_keys/#{fqdn}.pem"
  pe_new_cert = "#{ssldir}/certs/#{fqdn}.pem"

  # pe 2016.4.0 removes the pe-internal-orchestrator.pem file but old systems
  # will still have the client cert (which won't work), so pick based on 
  # using pe-internal-orchestrator.pem if its available
  if File.exist?(pe_old_pk)
    pk    = pe_old_pk
    cert  = pe_old_cert
  else
    pk    = pe_new_pk
    cert  = pe_new_cert
  end

  CONF = {
    host: Socket.gethostname,
    port: 4433,
    cert: cert,
    key: pk,
    cacert: ssldir + '/certs/ca.pem'
  }

  BASE_URI = '/rbac-api/v1'

  #
  # user
  # 

  def self.get_users
    JSON.parse(_request(:get, '/users').body)
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
    JSON.parse(_request(:get, "/users/#{id}").body)
  end

  def self.ensure_user(login, email, display_name, password=nil, role_ids=[])
    if get_user_id(login)
      # existing user
      update_user(login, email, display_name, role_ids)
      if password
        change_password(login, password)
      end
    else
      # new user
      create_user(login, email, display_name, password, role_ids)
    end

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
    user = get_user(get_user_id(login))
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
    JSON.parse(_request(:get, "/roles").body)
  end

  def self.get_role(id)
    JSON.parse(_request(:get, "/roles/#{id}").body)
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

  
  # get the role id for a display name
  # eg ['Code Deployers', 'blah'] => [4,8]
  def self.get_role_ids(display_names)
    if ! display_names.is_a? Array
      display_names = [display_names]
    end
    roles = get_roles
    ids = []
    display_names.each { |display_name|
      found=get_role_id(display_name)
      if !found
        raise("RBAC role '#{display_name}' not found")
      end
      ids.push(found)
    }
    ids
  end

  # CREATE
  def self.ensure_role(display_name, description, permissions=[], users=[])
    if get_role_id(display_name)
      update_role(display_name, description, permissions, users)
    else
      create_role(display_name, description, permissions, users)
    end
  end
  
  def self.create_role(display_name, description, permissions=[], users=[])
    role = {
      "display_name"  => display_name,
      "description"   => description,
      "permissions"   => permissions,
      "user_ids"      => users,
      "group_ids"     => [], # doesn't seem to be used yet
    }
    _request(:post, '/roles', role)
  end

  def self.update_role(display_name, description=nil, permissions=nil, user_ids=nil, group_ids=nil)
    role_id = get_role_id(display_name)
    if role_id 
      role = get_role(role_id)
      role['display_name'] = display_name ? display_name : role['display_name']
      role['description'] = description ? display_name : role['description']
      role['permissions'] = permissions ? display_name : role['permissions']
      role['user_ids'] = user_ids ? display_name : role['user_ids']
      role['group_ids'] = group_ids ? display_name : role['group_ids']

      _request(:put, "/roles/#{role_id}", role)
    else
      raise("No such role exists: #{display_name} create it first or use ensure_role")
    end
  end
  

  #
  # Permissions
  #
  def self.get_permissions()
    _request(:get, "/types")
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

    JSON.parse(_request(:post, '/auth/token', payload))['token']
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
