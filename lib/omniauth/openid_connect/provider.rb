#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

module OmniAuth
  module OpenIDConnect
    class Provider
      def self.inherited(subclass)
        all << subclass
      end

      def self.all
        @providers ||= Set.new
      end

      def self.available
        all.select(&:available?)
      end

      def self.available?
        !!config["secret"] && !!config["identifier"]
      end

      def self.provider_name
        self.name.demodulize.downcase
      end

      def self.config
        Hash(Hash(OpenProject::Configuration["openid_connect"])[provider_name])
      end

      def to_hash
        options
      end

      def options
        {
          :name => self.class.provider_name,
          :scope => [:openid, :email, :profile],
          :client_options => client_options
        }
      end

      def client_options
        {
          :port => 443,
          :scheme => "https",
          :host => host,
          :identifier => identifier,
          :secret => secret,
          :redirect_uri => redirect_uri
        }
      end

      def host
        raise NotImplemented("Host required")
      end

      def identifier
        self.class.config["identifier"]
      end

      def secret
        self.class.config["secret"]
      end

      ##
      # Path to which to redirect after successful authentication with the provider.
      def redirect_path
        "/auth/#{self.class.provider_name}/callback"
      end

      def redirect_uri
        "#{Setting.protocol}://#{Setting.host_name}#{redirect_path}"
      end
    end
  end
end
