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

module API
  module V3
    module Utilities
      module PathHelper
        include API::Utilities::UrlHelper

        class ApiV3Path
          def self.root
            "#{root_path}api/v3"
          end

          def self.activity(id)
            "#{root}/activities/#{id}"
          end

          def self.attachment(id)
            "#{root}/attachments/#{id}"
          end

          def self.available_assignees(project_id)
            "#{project(project_id)}/available_assignees"
          end

          def self.available_responsibles(project_id)
            "#{project(project_id)}/available_responsibles"
          end

          def self.available_watchers(work_package_id)
            "#{work_package(work_package_id)}/available_watchers"
          end

          def self.categories(project_id)
            "#{project(project_id)}/categories"
          end

          def self.preview_textile(link)
            preview_markup(:textile, link)
          end

          def self.priorities
            "#{root}/priorities"
          end

          def self.projects
            "#{root}/projects"
          end

          def self.project(id)
            "#{projects}/#{id}"
          end

          def self.query(id)
            "#{root}/queries/#{id}"
          end

          def self.relation(id)
            "#{root}/relations/#{id}"
          end

          def self.statuses
            "#{root}/statuses"
          end

          def self.status(id)
            "#{statuses}/#{id}"
          end

          def self.users
            "#{root}/users"
          end

          def self.user(id)
            "#{users}/#{id}"
          end

          def self.versions(project_id)
            "#{project(project_id)}/versions"
          end

          def self.versions_projects(version_id)
            "#{root}/versions/#{version_id}/projects"
          end

          def self.watcher(id, work_package_id)
            "#{work_package(work_package_id)}/watchers/#{id}"
          end

          def self.work_packages
            "#{root}/work_packages"
          end

          def self.work_package(id)
            "#{work_packages}/#{id}"
          end

          def self.work_package_activities(id)
            "#{work_package(id)}/activities"
          end

          def self.work_package_relations(id)
            "#{work_package(id)}/relations"
          end

          def self.work_package_relation(id, work_package_id)
            "#{work_package_relations(work_package_id)}/#{id}"
          end

          def self.work_package_form(id)
            "#{work_package(id)}/form"
          end

          def self.work_package_watchers(id)
            "#{work_package(id)}/watchers"
          end

          def self.root_path
            @@root_path ||= Class.new.tap do |c|
              c.extend(::API::V3::Utilities::PathHelper)
            end.root_path
          end

          def self.preview_markup(method, link)
            path = "#{root}/render/#{method}"

            path += "?#{link}" unless link.nil?

            path
          end
        end

        def api_v3_paths
          ApiV3Path
        end
      end
    end
  end
end
