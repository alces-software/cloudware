#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Cloudware.
#
# Alces Cloudware is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Cloudware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You hould have received a copy of the GNU General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Cloudware, please visit:
# https://github.com/alces-software/cloudware
#==============================================================================
require 'aws-sdk'

CloudFormation = Aws::CloudFormation
EC2 = Aws::EC2

module Cloudware
  class Aws
    def initialize(region)
      @cfn = CloudFormation::Client.new(region: region)
      @ec2 = EC2::Client.new(region: region)
    end

    def regions
      @regions = []
      @ec2.describe_regions().regions.each do |r|
        @regions.push(r.region_name)
      end
      @regions
    end

    def create_domain(name, id, networkcidr, prvsubnetcidr, mgtsubnetcidr)
      template = 'aws-network-base.json'
      params = [
        { parameter_key: 'cloudwareDomain', parameter_value: name },
        { parameter_key: 'cloudwareId', parameter_value: id },
        { parameter_key: 'networkCidr', parameter_value: networkcidr },
        { parameter_key: 'prvsubnetcidr', parameter_value: prvsubnetcidr },
        { parameter_key: 'mgtsubnetcidr', parameter_value: mgtsubnetcidr }
      ]
    end

    def deploy(name, template, params)
      template = File.read(File.expand_path(File.join(__dir__, "../../templates/#{template}")))
      @cfn.create_stack stack_name: name, template_body: template, parameters: params
      @cfn.wait_until :stack_create_complete, stack_name: name
    end

    def destroy(name)
      @cfn.delete_stack stack_name: name
      @cfn.wait_until :stack_delete_complete, stack_name: name
    end
  end
end
