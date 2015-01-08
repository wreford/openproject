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

class VersionPolicy < BasePolicy
  private

  def cache
    @cache ||= Hash.new do |hash, version|
      # copy checks for the move_work_packages permission. This makes
      # sense only because the work_packages/moves controller handles
      # copying multiple work packages.
      hash[version] = {
        show: show_allowed?(version)
      }
    end
  end

  def show_allowed?(version)
    @show_cache ||= Hash.new do |hash, queried_version|
      permissions = [:view_work_packages, :manage_versions]

      hash[queried_version] = permissions.any? do |permission|
        allowed_condition = Project.allowed_to_condition(user, permission)

        queried_version.projects.where(allowed_condition).exists?
      end
    end

    @show_cache[version]
  end
end
