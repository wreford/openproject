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
    module WorkPackages
      class WorkPackagesAPI < Grape::API
        resources :work_packages do

          params do
            requires :id, desc: 'Work package id'
          end
          namespace ':id' do

            helpers do
              attr_reader :work_package

              def write_work_package_attributes
                if request_body
                  payload = ::API::V3::WorkPackages::Form::WorkPackagePayloadRepresenter
                              .new(@work_package, enforce_lock_version_validation: true)

                  begin
                    payload.from_json(request_body.to_json)
                  rescue ::API::Errors::Form::InvalidResourceLink => e
                    fail ::API::Errors::Validation.new(e.message)
                  end
                end
              end

              def request_body
                env['api.request.body']
              end

              def write_request_valid?
                contract = WorkPackageContract.new(@representer.represented, current_user)

                # We need to merge the contract errors with the model errors in
                # order to have them available at one place.
                unless contract.validate & @representer.represented.valid?
                  contract.errors.keys.each do |key|
                    contract.errors[key].each do |message|
                      @representer.represented.errors.add(key, message)
                    end
                  end
                end

                @representer.represented.errors.count == 0
              end
            end

            before do
              @work_package = WorkPackage.find(params[:id])
              @representer = WorkPackageRepresenter.new(work_package,
                                                        current_user: current_user)
            end

            get do
              authorize({ controller: :work_packages_api, action: :get },
                        context: @work_package.project)
              @representer
            end

            patch do
              write_work_package_attributes

              send_notifications = !(params.has_key?(:notify) && params[:notify] == 'false')
              update_service = UpdateWorkPackageService.new(current_user,
                                                            @representer.represented,
                                                            nil,
                                                            send_notifications)

              if write_request_valid? && update_service.save
                @representer.represented.reload
                @representer
              else
                fail ::API::Errors::ErrorBase.create(@representer.represented.errors.dup)
              end
            end

            resource :activities do

              helpers do
                def save_work_package(work_package)
                  if work_package.save
                    representer = ::API::V3::Activities::ActivityRepresenter.new(work_package.journals.last, current_user: current_user)

                    representer
                  else
                    fail ::API::Errors::Validation.new(work_package)
                  end
                end
              end

              params do
                requires :comment, type: String
              end
              post do
                authorize({ controller: :journals, action: :new }, context: @work_package.project)

                @work_package.journal_notes = params[:comment]

                save_work_package(@work_package)
              end

            end

            mount ::API::V3::WorkPackages::WatchersAPI
            mount ::API::V3::Relations::RelationsAPI
            mount ::API::V3::WorkPackages::Form::FormAPI

          end

        end
      end
    end
  end
end
