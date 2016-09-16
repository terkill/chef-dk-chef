# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: provider_chef_dk_debian
#
# Copyright 2014-2016, Jonathan Hartman
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
#

require 'chef/provider/lwrp_base'
require_relative 'provider_chef_dk'

class Chef
  class Provider
    class ChefDk < LWRPBase
      # A Chef provider for the Chef-DK .deb packages
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Debian < ChefDk
        provides :chef_dk, platform_family: 'debian'

        private

        #
        # Download and install the Chef-DK .deb. The `dpkg_package` resource
        # doesn't accept a remote source, so this must be done in two steps.
        #
        # (see Chef::Provider::ChefDk#install!)
        #
        def install!
          src = package_source
          dst = ::File.join(Chef::Config[:file_cache_path],
                            ::File.basename(src))
          chk = package_checksum
          remote_file dst do
            source src
            checksum chk
          end
          dpkg_package dst do
              options '--skip-same-version'
          end
        end

        #
        # Use the `dpkg_package` resource to remove the Chef-DK.
        #
        # (see Chef::Provider::ChefDk#remove!)
        #
        def remove!
          dpkg_package 'chefdk' do
            action :remove
          end
        end
      end
    end
  end
end
