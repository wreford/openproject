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

require 'spec_helper'
require 'rack/test'

describe 'API v3 Status resource' do
  include Rack::Test::Methods

  let(:current_user) { FactoryGirl.create(:user) }
  let(:role) { FactoryGirl.create(:role, permissions: []) }
  let(:project) { FactoryGirl.create(:project, is_public: false) }
  let(:statuses) { FactoryGirl.create_list(:status, 4) }

  describe 'statuses' do
    describe '#get' do
      subject(:response) { last_response }

      context 'logged in user' do
        let(:get_path) { '/api/v3/statuses' }
        before do
          allow(User).to receive(:current).and_return current_user
          member = FactoryGirl.build(:member, user: current_user, project: project)
          member.role_ids = [role.id]
          member.save!

          statuses

          get get_path
        end

        it_behaves_like 'API V3 collection response', 4, 4, 'Status'
      end
    end
  end

  describe 'statuses/:id' do
    describe '#get' do
      let(:user) { FactoryGirl.create(:user, member_in_project: project) }
      let(:status) { statuses.first }

      subject(:response) { last_response }

      before do
        allow(User).to receive(:current).and_return(user)

        get path
      end

      context 'valid status id' do
        let(:path) { "/api/v3/statuses/#{status.id}" }

        it { expect(response.status).to eq(200) }
      end

      context 'invalid status id' do
        let(:path) { '/api/v3/statuses/bogus' }

        it_behaves_like 'not found', 'bogus', 'Status'
      end
    end
  end
end
