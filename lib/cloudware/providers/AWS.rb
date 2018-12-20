# frozen_string_literal: true

require 'aws-sdk-cloudformation'
require 'aws-sdk-ec2'
require 'providers/base'

module Cloudware
  module Providers
    module AWS
      class Credentials < Base::Credentials
        def self.build
          Aws::Credentials.new(config.access_key_id, config.secret_access_key)
        end

        private

        def self.config
          Config.aws
        end
      end

      class Machine < Base::Machine
        def status
          instance.state.name
        end

        def off
          instance.stop
        end

        def on
          instance.start
        end

        private

        def instance
          Aws::EC2::Resource.new(
            region: region, credentials: credentials
          ).instance(machine_id)
        end
        memoize :instance
      end

      class Client < Base::Client
        def deploy(tag, template)
          client.create_stack(stack_name: tag, template_body: template)
          client.wait_until(:stack_create_complete, stack_name: tag)
                .stacks
                .first
                .outputs
                .each_with_object({}) do |output, memo|
                  memo[output.output_key] = output.output_value
                end
        end

        def destroy(tag)
          client.delete_stack(stack_name: tag)
          client.wait_until(:stack_delete_complete, stack_name: tag)
        end

        private

        def client
          Aws::CloudFormation::Client.new(
            region: region, credentials: credentials
          )
        end
        memoize :client
      end
    end
  end
end
