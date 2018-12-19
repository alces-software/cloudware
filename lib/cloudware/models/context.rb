# frozen_string_literal: true

require 'erb'
require 'ostruct'

module Cloudware
  module Models
    class Context < Application
      attr_reader :region
      delegate :provider, to: Config

      def initialize(region: nil, **other_args)
        super(**other_args)
        @region = region || Config.default_region
      end

      def deployments
        @deployments ||= Data.load(path, default_value: []).map do |data|
          Deployment.new(**data)
        end
      end

      def deployments=(input_deployments)
        @deployments = [] # Reset the cache
        input_deployments.each do |deployment|
          with_deployment(deployment)
        end
      end

      def machines
        Machine.build_from_context(self)
      end

      def results
        deployments.map(&:results)
                   .each_with_object({}) do |results, memo|
          memo.merge!(results || {})
        end
      end

      def with_deployment(deployment)
        existing_index = deployments.find_index do |cur_deployment|
          cur_deployment.name == deployment.name
        end
        if existing_index
          deployments[existing_index] = deployment
        else
          deployments.push(deployment)
        end
      end

      def remove_deployment(deployment)
        deployments.delete_if { |d| d.name == deployment.name }
      end

      def save
        save_data = deployments.map(&:to_h)
        Data.dump(path, save_data)
      end

      def find_deployment(name)
        deployments.find { |d| d.name == name }
      end

      def render(template)
        ERB.new(template, nil, '-').result(binding)
      end

      private

      def path
        File.join(Config.content_path,
                  'contexts',
                  provider,
                  "#{region}.yaml")
      end
    end
  end
end
