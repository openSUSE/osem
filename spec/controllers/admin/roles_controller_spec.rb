# frozen_string_literal: true

require 'spec_helper'

describe Admin::RolesController do
  let(:conference) { create(:conference) }
  let(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let(:cfp_role) { Role.find_by(name: 'cfp', resource: conference) }
  let(:admin) { create(:admin) }

  let!(:user1) { create(:user, email: 'user1@osem.io') }
  let!(:user2) { create(:user, email: 'user2@osem.io') }

  describe 'GET #index' do
    before :each do
      sign_in(admin)
      get :index, params: { conference_id: conference.short_title }
    end

    it 'assigns default value to selection variable' do
      expect(assigns(:selection)).to eq 'organizer'
    end

    it 'finds the correct role' do
      expect(assigns(:role)).to eq organizer_role
    end
  end

  describe 'GET #show' do
    before :each do
      sign_in(admin)
      get :show, params: { conference_id: conference.short_title,
                           id:            'organizer' }
    end

    it 'assigns correct value to selection variable' do
      expect(assigns(:selection)).to eq 'organizer'
    end

    it 'assigns correct value to role variable' do
      expect(assigns(:role)).to eq organizer_role
    end
  end

  describe 'PATCH #update' do
    before :each do
      sign_in admin
      patch :update, params: { conference_id: conference.short_title,
                               id:            'cfp',
                               role:          { description: 'New description for cfp role!' } }
    end

    it 'changes the description of the role' do
      expect(cfp_role.description).to eq 'New description for cfp role!'
    end
  end

  describe 'POST #toggle' do
    before :each do
      sign_in admin
      post :toggle_user, params: { conference_id: conference.short_title,
                                   user:          { email: 'user1@osem.io' },
                                   id:            'cfp' }
    end

    context 'assigns correct values to variables' do
      it 'assigns correct value to selection variable' do
        expect(assigns(:selection)).to eq 'cfp'
      end

      it 'assigns correct value to role variable' do
        expect(assigns(:role)).to eq cfp_role
      end

      it 'assigns role to user' do
        expect(user1.roles).to eq [cfp_role]
      end
    end

    context 'adds role to user' do
      it 'adds second user' do
        post :toggle_user, params: { conference_id: conference.short_title,
                                     user:          { email: 'user2@osem.io' },
                                     id:            'cfp' }

        expect(user2.roles).to eq [cfp_role]
      end

      it 'assigns second role to user' do
        post :toggle_user, params: { conference_id: conference.short_title,
                                     user:          { email: 'user1@osem.io' },
                                     id:            'organizer' }

        expect(user1.roles).to contain_exactly(cfp_role, organizer_role)
      end
    end

    context 'removes role from user' do
      it 'removes role from user' do
        post :toggle_user, params: { conference_id: conference.short_title,
                                     user:          { email: 'user1@osem.io', state: 'false' },
                                     id:            'cfp' }

        expect(user1.roles).to eq []
      end

      it 'removes second role from user' do
        post :toggle_user, params: { conference_id: conference.short_title,
                                     user:          { email: 'user1@osem.io' },
                                     id:            'organizer' }

        expect(user1.roles).to contain_exactly(cfp_role, organizer_role)

        post :toggle_user, params: { conference_id: conference.short_title,
                                     user:          { email: 'user1@osem.io', state: 'false' },
                                     id:            'cfp' }

        user1.reload
        expect(user1.roles).to eq [organizer_role]
      end
    end

    it 'does not remove role if user is the last organizer' do
      # Add role organizer
      post :toggle_user, params: { conference_id: conference.short_title,
                                   user:          { email: 'user1@osem.io', state: 'true' },
                                   id:            'organizer' }
      expect(organizer_role.users).to eq [user1]

      # Try to remove role organizer, when there is only 1 user as organizer
      post :toggle_user, params: { conference_id: conference.short_title,
                                   user:          { email: 'user1@osem.io', state: 'false' },
                                   id:            'organizer' }
      expect(organizer_role.users).to eq [user1]
    end
  end
end
