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

# code-coverage not requires new escort: https://github.com/skorks/escort/issues/13
#require 'simplecov'
#SimpleCov.start do
#  add_filter '/spec/'
#end
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "pe_rbac"
require "pe_rbac/core"
require 'fake_rbac_service'

PeRbac::Core::set_ssldir("./spec/fixtures/ssl")
PeRbac::Core::set_fqdn("localhost")
Thread.start { FakeRbacService::WEBrick.run! }
