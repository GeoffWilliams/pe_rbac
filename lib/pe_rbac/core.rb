module PeRbac
  module Core
    @@ssldir = '/etc/puppetlabs/puppet/ssl'
    @@fqdn = %x(facter fqdn).strip.downcase

    def self.set_ssldir(ssldir)
      @@ssldir = ssldir
    end

    def self.get_ssldir
      @@ssldir
    end

    def self.set_fqdn(fqdn)
      @@fqdn = fqdn
    end

    def self.get_fqdn
      @@fqdn
    end

    def self.get_conf
      pe_old_pk   = "#{@@ssldir}/private_keys/pe-internal-orchestrator.pem"
      pe_old_cert = "#{@@ssldir}/certs/pe-internal-orchestrator.pem"
      pe_new_pk   = "#{@@ssldir}/private_keys/#{@@fqdn}.pem"
      pe_new_cert = "#{@@ssldir}/certs/#{@@fqdn}.pem"

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

      conf = {
        host: @@fqdn,
        port: 4433,
        cert: cert,
        key: pk,
        cacert: @@ssldir + '/certs/ca.pem'
      }
    end

    def self.request(method, path, payload=nil, raw=false)
      conf = get_conf()
      url = "https://#{conf[:host]}:#{conf[:port]}#{PeRbac::BASE_URI}#{path}"
      if payload
        if raw
          _payload=payload
        else
          _payload=payload.to_json
        end
      else
        _payload=nil
      end
      begin
        RestClient::Request.execute(
          method: method,
          url: url,
          ssl_ca_file: conf[:cacert],
          ssl_client_cert: OpenSSL::X509::Certificate.new(File.read(conf[:cert])),
          ssl_client_key: OpenSSL::PKey::RSA.new(File.read(conf[:key])),
          ssl_version: "TLSv1_2", #:TLSv1_2,
          headers: {:content_type => :json, :accept => :json},
          payload: _payload,
        )
      rescue RestClient::ExceptionWithResponse => e
        Escort::Logger.error.error url
        Escort::Logger.error.error _payload
        Escort::Logger.error.error e.response
        raise "API Error"
      end
    end


    # return a new array of permissions, adding the permission `ensure` to the
    # existing permissions if required
    def self.merge_permissions(existing, ensure_perms)
      # duplicate existing array of hash
      permissions = existing.map do |e| e.dup end

      ensure_perms.each { |ensure_perm|
        ensure_perm_exists = false
        existing.each { |existing_perm|
          if  existing_perm['object_type']  == ensure_perm['object_type'] and
              existing_perm['action']       == ensure_perm['action'] and
              existing_perm['instance']     == ensure_perm['instance']
            ensure_perm_exists = true
          end
        }
        if ! ensure_perm_exists
          permissions.push(ensure_perm)
        end
      }

      permissions
    end
  end

end
