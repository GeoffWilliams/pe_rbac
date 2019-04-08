#
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

require 'sinatra/base'
require 'webrick'
require 'webrick/log'
require "webrick/https"
require 'rack'

module FakeRbacService
  class FakeRbacService < Sinatra::Base
    #set :port, 4433
    JSON_DIR = './spec/fixtures/json'

    def read_json(verb, operation)
      File.read(File.join(JSON_DIR, verb, operation + '.json'))
    end

    # All users
    get '/rbac-api/v1/users' do
      read_json('get', 'users')
    end

    # a specific user
    get '/rbac-api/v1/users/:id' do
      found = nil
      JSON.parse(read_json('get', 'users')).each { |j|
        if j['id'] == params[:id]
          found = j
        end
      }
      if found
        payload = found.to_json
      else
        status 404
      end
    end

    # create a user
    post '/rbac-api/v1/users' do
      status 201
    end

    # update a user
    put '/rbac-api/v1/users/:id' do
      status 200
    end

    # generate a reset token
    post '/rbac-api/v1/users/:id/password/reset' do
      "RESET_TOKEN_OK"
    end

    # reset using a token
    post '/rbac-api/v1/auth/reset' do
      "RESET_USED_TOKEN_OK"
    end

    # list all roles
    get '/rbac-api/v1/roles' do
      read_json('get', 'roles')
    end

    # list a specific role
    get '/rbac-api/v1/roles/:id' do
      found = nil
      JSON.parse(read_json('get', 'roles')).each { |j|
        if j['id'].to_s == params[:id]
          found = j
        end
      }
      if found
        payload = found.to_json
      else
        status 404
      end
    end

    # create a role
    post '/rbac-api/v1/roles' do
      status 201
    end

    # update a role
    put '/rbac-api/v1/roles/:id' do
      status 200
    end

    # get all permissions
    get '/rbac-api/v1/types' do
      read_json('get', 'types')
    end

    post '/rbac-api/v1/auth/token' do
      json = JSON.parse(request.body.read)
      login     = json['login']
      password  = json['password']

      if login == "admin"
        res = {"token" => "DEADBEEF"}
      else
        status 401
      end

      res.to_json
    end
  end

  module WEBrick
    def self.run!
      webrick_options = {
        :Port                 => 4433,
        :Logger               => ::WEBrick::Log::new($stdout, ::WEBrick::Log::DEBUG),
        :SSLEnable            => true,
        :force_ssl            => true,
        :SSLVerifyClient      => OpenSSL::SSL::VERIFY_PEER,
        :SSLCACertificateFile => "./spec/fixtures/ssl/certs/ca.pem",
        :SSLCertificate       => OpenSSL::X509::Certificate.new(  File.open("./spec/fixtures/ssl/certs/localhost.pem").read),
        :SSLPrivateKey        => OpenSSL::PKey::RSA.new(          File.open("./spec/fixtures/ssl/private_keys/localhost.pem").read),
        :SSLCertName          => [ [ "CN",'localhost' ] ]
      }
      begin
      Rack::Handler::WEBrick.run FakeRbacService, webrick_options
      rescue IOError => e
        # we get an exception as ruby exits and STDIO has gone away
        # so catch this type of error (only) and exit quietly...
        if ! (e.message =~ /closed/)
          puts e.backtrace
        end
      end
    end
  end
  # def self.run!
  #   certificate_content = File.open(ssl_certificate).read
  #   key_content = File.open(ssl_key).read
  #
  #   server_options = {
  #     :Host => bind,
  #     :Port => port,
  #     :SSLEnable => true,
  #     :SSLCertificate => OpenSSL::X509::Certificate.new(certificate_content),
  #     # 123456 is the Private Key Password
  #     :SSLPrivateKey => OpenSSL::PKey::RSA.new(key_content,"123456")
  #   }
  #
  #   Rack::Handler::WEBrick.run self, server_options do |server|
  #     [:INT, :TERM].each { |sig| trap(sig) { server.stop } }
  #     server.threaded = settings.threaded if server.respond_to? :threaded=
  #     set :running, true
  #   end
  # end
end
