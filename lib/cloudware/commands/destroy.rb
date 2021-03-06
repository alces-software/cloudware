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

module Cloudware
  module Commands
    class Destroy < Command
      attr_reader :name

      def initialize(*a)
        require 'cloudware/models/deployment'
        super
      end

      def run!(name)
        name == 'domain' ? domain : node(name)
      end

      def domain
        with_spinner("Destroying domain ...", done: 'Done') do
          Models::Domain.destroy!(__config__.current_cluster)
        end
      end

      def node(name)
        with_spinner("Destroying resources for #{name}...", done: 'Done') do
          Models::Node.destroy!(__config__.current_cluster, name)
        end
      end

      def delete(name, force: false)
        if name == 'domain'
          Models::Domain.delete!(__config__.current_cluster, force: force)
        else
          Models::Node.delete!(__config__.current_cluster, name, force: force)
        end
      end
    end
  end
end
