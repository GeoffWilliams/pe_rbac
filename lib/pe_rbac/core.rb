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

require 'escort'
require 'excon'

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
        connection = Excon.new(url,
                               client_cert: conf[:cert],
                               client_key: conf[:key],
                               ssl_ca_file: conf[:cacert],
                               ssl_version: :TLSv1_2)
        result = connection.request(method: method,
                                    headers: {"content-type"=> "application/json", "accept"=>"application/json"},
                                    body: _payload)
        if result.status >= 400
          # There doesn't seem to be a built-in way to check for error codes
          # without individually specifying each allowable 'good' status (:expect..)
          # so lets just check for anything that smells bad.  Note that the API
          # sometimes gives us a 3xx code but there doesn't seem to be a need
          # for us to follow the redirection...
          Escort::Logger.error.error "Error #{result.status} encountered for '#{url}':  Requested '#{_payload}', got '#{result.body}'"
          result = false
        end
      rescue Excon::Error => e
        Escort::Logger.error.error "Error (#{e.message}) for: #{url}, #{_payload}"
        result = false
      end
      result
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
