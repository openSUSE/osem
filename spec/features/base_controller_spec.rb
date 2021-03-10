# frozen_string_literal: true

require 'spec_helper'

feature 'BaseController' do
  let(:conference) { create(:conference) }
  let(:user) { create(:user) }

  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:volunteers_coordinator_role) { Role.find_by(name: 'volunteers_coordinator', resource: conference) }
  let!(:cfp_role) { Role.find_by(name: 'cfp', resource: conference) }
  let!(:info_desk_role) { Role.find_by(name: 'info_desk', resource: conference) }

  describe 'GET #verify_user_admin' do
    context 'when user is a guest' do
      before(:each) do
        sign_out
      end

      it 'redirects to sign in page' do
        visit admin_conferences_path
        expect(current_path).to eq new_user_session_path
      end
    end

    context 'when user is ' do
      before(:each) do
        sign_in(user)
      end

      it 'not an admin it redirects to root_path' do
        visit admin_conferences_path
        expect(current_path).to eq root_path
        expect(flash).to eq 'You are not authorized to access this page.'
      end

      it 'an admin they can access the admin area' do
        user.is_admin = true
        visit admin_conferences_path
        expect(current_path).to eq admin_conferences_path
      end

      it 'an organizer they can access the admin area' do
        user.role_ids = organizer_role.id
        visit admin_conferences_path
        expect(current_path).to eq admin_conferences_path
      end

      it 'a volunteers_coordinator they can access the admin area' do
        user.role_ids = volunteers_coordinator_role.id
        visit admin_conferences_path
        expect(current_path).to eq admin_conferences_path
      end

      it 'a cfp they can access the admin area' do
        user.role_ids = cfp_role.id
        visit admin_conferences_path
        expect(current_path).to eq admin_conferences_path
      end

      it 'an info_desk they can access the admin area' do
        user.role_ids = info_desk_role.id
        visit admin_conferences_path
        expect(current_path).to eq admin_conferences_path
      end
    end
  end
end
