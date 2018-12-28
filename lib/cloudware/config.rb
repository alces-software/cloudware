# frozen_string_literal: true

#
# =============================================================================
# Copyright (C) 2018 Stephen F. Norledge and Alces Software Ltd
#
# This file is part of Alces Cloudware.
#
# Alces Cloudware is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Alces Cloudware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Alces Cloudware.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Cloudware, please visit:
# https://github.com/alces-software/cloudware
# ==============================================================================
#

require 'ostruct'

require 'active_support/core_ext/module/delegation'

require 'cloudware/data'

module Cloudware
  class Config
    PATH = File.join(Cloudware.root_dir, 'etc/config.yml')

    class << self
      def cache
        @cache ||= new
      end

      delegate_missing_to :cache
    end

    attr_accessor :log_file, :aws, :azure, :providers
    attr_reader :provider, :default_region, :content_path

    def initialize
      config = Data.load(PATH)

      self.log_file = config[:general][:log_file] || log.error('Unable to load log_file')

      # Providers
      self.azure = OpenStruct.new(config[:provider][:azure])
      self.aws = OpenStruct.new(config[:provider][:aws])

      # Providers List (identifying valid/present providers)
      self.providers = []
      config['provider'].each do |a, b|
        providers << a if b.first[1].nil? || !b.first[1].empty?
      end

      @default = OpenStruct.new(config[:default])
      @provider = ENV['CLOUDWARE_PROVIDER']
      @default_region = config[:provider][provider.to_sym][:default_region]

      @content_path = File.join(Cloudware.root_dir, 'var')
    end

    def log
      Cloudware.log
    end
  end
end
