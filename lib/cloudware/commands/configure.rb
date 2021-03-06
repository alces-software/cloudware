# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Cloud.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Cloud is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Cloud. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Cloud, please visit:
# https://github.com/openflighthpc/flight-cloud
#===============================================================================

require 'tty-prompt'

module Cloudware
  module Commands
    class Configure < Command
      def run
        prompt = TTY::Prompt.new
        puts "Continuing will remove the comments from the config file: #{Config.path}"
        return unless prompt.ask(<<~DESC.chomp, convert: :bool)
          Do you wish to continue (y/n)?
        DESC
        require 'cloudware/providers/aws_interface'
        require 'cloudware/providers/azure_interface'
        {
          'aws': Providers::AWSInterface::Credentials.required_keys,
          'azure': Providers::AzureInterface::Credentials.required_keys
        }.each do |provider, keys|
          if prompt.ask("Configure #{provider} (y/n)?", convert: :bool)
            Config.create_or_update do |conf|
              data = conf.public_send(provider, allow_missing: true)
              keys.each do |key|
                data[key] = prompt.ask("What is the #{key}?", default: data[key])
              end
              conf.public_send("#{provider}=", data)
            end
          end
        end
      end
    end
  end
end
