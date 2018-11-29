# frozen_string_literal: true

require 'tty-table'

module Cloudware
  module Commands
    module Infos
      class Machine < Command
        include Concerns::ExistingDeployment
        attr_reader :machine_name, :deployment_name

        def run
          @deployment_name = options.deployment
          @machine_name = argv[0]
          machine.tags.each { |row| table << row }
          puts table.render(:unicode)
        end

        private

        def machine
          Models::Machine.new(name: machine_name, deployment: deployment)
        end
        memoize :machine

        def table
          TTY::Table.new header: ['Tag', 'Value']
        end
        memoize :table
      end
    end
  end
end
