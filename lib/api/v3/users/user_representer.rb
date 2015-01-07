#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
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

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module Users
      class UserRepresenter < ::API::Decorators::Single
        include AvatarHelper

        link :self do
          {
            href: api_v3_paths.user(represented.id),
            title: "#{represented.name} - #{represented.login}"
          }
        end

        link :removeWatcher do
          {
            href: api_v3_paths.watcher(represented.id, work_package.id),
            method: :delete,
            title: 'Remove watcher'
          } if work_package && current_user_allowed_to(:delete_work_package_watchers, work_package)
        end

        property :id, render_nil: true
        property :login, render_nil: true
        property :subtype, getter: -> (*) { type }, render_nil: true
        property :firstname, as: :firstName, render_nil: true
        property :lastname, as: :lastName, render_nil: true
        property :name, render_nil: true
        property :mail, render_nil: true
        property :avatar, getter: -> (*) { avatar_url(represented) },
                          render_nil: true,
                          exec_context: :decorator
        property :created_at, getter: -> (*) { created_on.utc.iso8601 }, render_nil: true
        property :updated_at, getter: -> (*) { updated_on.utc.iso8601 }, render_nil: true
        property :status, getter: -> (*) { status }, render_nil: true

        def _type
          'User'
        end

        def current_user_allowed_to(permission, work_package)
          current_user && current_user.allowed_to?(permission, work_package.project)
        end

        private

        def current_user
          context[:current_user]
        end

        def work_package
          context[:work_package]
        end
      end
    end
  end
end
