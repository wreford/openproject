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

##
# Implements the deletion of a user through another one.
class DeleteUser < Struct.new :user, :actor
  ##
  # Deletes the given user if allowed.
  #
  # @return The deleted user or nil if the user could not be deleted.
  def call
    if self.class.deletion_allowed? user, actor
      delete_user user
    else
      nil
    end
  end

  ##
  # Checks if a given user may be deleted by another one.
  #
  # @param user [User] User to be deleted.
  # @param actor [User] User who wants to delete the given user.
  def self.deletion_allowed?(user, actor)
    if actor == user
      Setting.users_deletable_by_self?
    else
      actor.admin && Setting.users_deletable_by_admins?
    end
  end

  ##
  # All pure functions which are supposed to be easily re-usable, hence the module_functions.
  # When included these functions will be private, leaving #call as the only public interface
  # method of DeleteUser. They can be used directly on the Functions module as well, though.
  module Functions
    module_function

    def delete_user(user)
      delete_associated_private_queries user
      reassign_associated user
      remove_from_filter user

      user.destroy
    end

    def delete_associated_private_queries(user)
      ::Query.delete_all ['user_id = ? AND is_public = ?', user.id, false]
    end

    def reassign_associated(user)
      substitute = DeletedUser.first

      [WorkPackage, Attachment, WikiContent, News, Comment, Message].each do |klass|
        klass.update_all ['author_id = ?', substitute.id], ['author_id = ?', user.id]
      end

      [TimeEntry, Journal, ::Query].each do |klass|
        klass.update_all ['user_id = ?', substitute.id], ['user_id = ?', user.id]
      end

      JournalManager.update_user_references user.id, substitute.id
    end

    def remove_from_filter(user)
      timelines_filter = ['planning_element_responsibles', 'planning_element_assignee', 'project_responsibles']
      substitute = DeletedUser.first

      timelines = Timeline.all(conditions: ['options LIKE ?', "%#{user.id}%"])

      timelines.each do |timeline|
        timelines_filter.each do |field|
          fieldOptions = timeline.options[field]
          if fieldOptions && index = fieldOptions.index(user.id.to_s)
            timeline.options_will_change!
            fieldOptions[index] = substitute.id.to_s
          end
        end

        timeline.save!
      end
    end
  end

  include Functions
end
