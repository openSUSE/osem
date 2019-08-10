# frozen_string_literal: true

require 'spec_helper'

describe Admin::InvitesController do

  let(:admin) { create(:admin) }
  let(:conference) { create(:conference) }
  let(:invite) { create(:invite, user_id: 1, end_date: '2019-08-12', invite_for: (t 'booth').capitalize, conference: conference) }

  context 'not logged in user' do

    describe 'GET index' do
      it 'does not render admin/invites#index' do
        get :index, params: { conference_id: conference.short_title }
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe 'GET new' do
      it 'does not render admin/invites#new' do
        get :new, params: { conference_id: conference.short_title }
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  context 'user is admin' do
    before :each do
      sign_in admin
    end

    describe 'GET index' do
      before { get :index, params: { conference_id: conference.short_title } }

      it 'renders index template' do
        expect(response).to render_template('index')
      end
    end

    describe 'GET new' do
      before { get :new, params: { conference_id: conference.short_title } }

      it 'assigns attributes for invite' do
        expect(assigns(:invite)).to be_a_new(Invite)
      end

      it 'renders new template' do
        expect(response).to render_template('new')
      end
    end

    describe 'POST #create' do
      context 'successfully created' do
        before { post :create, params: { invite: attributes_for(:invite), conference_id: conference.short_title } }

        it 'creates a new invite' do
          expected = expect do
            post :create, params: { invite: { emails: 'user1@example.com', end_date: Date.today, invite_for: (t 'booth').pluralize.to_s }, conference_id: conference.short_title }
          end
          expected.to change(Invite, :count).by(1)
        end

        it 'redirects to admin booth index' do
          expect(response).to redirect_to(admin_conference_invites_path)
        end

        it 'creates a new user on inviting for late submission' do
          expect(User.where(email: 'user@example.com')).to exist
        end

        it 'does not create a user with invalid email on inviting booth responsible' do
          expect(User.where(email: 'example')).not_to exist
        end

        it 'invited user should be a part of invites' do
          expect(Invite.pluck(:user_id)).to include(User.find_by(email: 'user@example.com').id)
        end
      end

      context 'create action fails' do
        before { post :create, params: { invite: attributes_for(:invite, emails: 'example'), conference_id: conference.short_title } }

        it 'does not create any invite on invalid email' do
          expected = expect do
            post :create, params: { invite: attributes_for(:invite, emails: 'example'), conference_id: conference.short_title }
          end
          expected.to_not change(Invite, :count)
        end

        it 'does not create a duplicate invite' do
          post :create, params: { invite: attributes_for(:invite), conference_id: conference.short_title }
          expected = expect do
            post :create, params: { invite: attributes_for(:invite), conference_id: conference.short_title }
          end
          expected.to change(Invite, :count).by(0)
        end

        it 'redirects to new' do
          expect(response).to render_template('new')
        end
      end
    end

    describe 'GET #edit' do
      before { get :edit, params: { id: invite.id, conference_id: conference.short_title } }

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end

      it 'assigns booth variable' do
        expect(assigns(:invite)).to eq invite
      end
    end

    describe 'PATCH #update' do
      context 'updates suchessfully' do
        before { patch :update, params: { id: invite.id, invite: attributes_for(:invite, end_date: '2019-08-13'), conference_id: conference.short_title } }

        it 'redirects to admin invite index path' do
          expect(response).to redirect_to admin_conference_invites_path
        end

        it 'shows success message' do
          expect(flash[:notice]).to match 'Invitation successfully updated.'
        end

        it 'updates invite' do
          invite.reload
          expect(invite.end_date).to eq(Date.parse('2019-08-13'))
        end
      end
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { conference_id: conference.short_title, id: invite.id } }

      it 'redirects to admin room index path' do
        expect(response).to redirect_to admin_conference_invites_path(conference_id: conference.short_title)
      end

      it 'shows success message in flash notice' do
        expect(flash[:notice]).to match('Invitation deleted.')
      end

      it 'deletes the room' do
        expect(Invite.count).to eq 0
      end
    end
  end
end
