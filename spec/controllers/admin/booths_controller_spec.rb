# frozen_string_literal: true

require 'spec_helper'

describe Admin::BoothsController do

  let(:admin) { create(:admin) }
  let(:conference) { create(:conference) }
  let(:booth) { create(:booth, title: 'Title', conference: conference) }
  let(:admin) { create(:admin) }

  context 'not logged in user' do

    describe 'GET index' do
      it 'does not render admin/booths#index' do
        get :index, params: { conference_id: conference.short_title }
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe 'GET show' do
      it 'does not render admin/booths#show' do
        get :show, params: { id: booth.id, conference_id: conference.short_title }
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

      it 'assigns attributes for booths' do
        expect(assigns(:booths)).to eq([booth])
      end

      it 'renders index template' do
        expect(response).to render_template('index')
      end
    end

    describe 'GET new' do
      before { get :new, params: { conference_id: conference.short_title } }

      it 'assigns attributes for booths' do
        expect(assigns(:booth)).to be_a_new(Booth)
      end

      it 'renders new template' do
        expect(response).to render_template('new')
      end
    end

    describe 'POST #create' do
      context 'successfully created' do
        before { post :create, params: { booth: attributes_for(:booth), conference_id: conference.short_title } }

        it 'creates a new booth' do
          expected = expect do
            post :create, params: { booth: attributes_for(:booth), conference_id: conference.short_title }
          end
          expected.to change { Booth.count }.by(1)
        end

        it 'redirects to admin booth index' do
          expect(response).to redirect_to(admin_conference_booths_path)
        end

        it 'has responsibles' do
          expect(booth.responsibles.count).to_not eq(0)
        end

        it 'shows success message' do
          expect(flash[:notice]).to match("#{(t 'booth').capitalize} successfully created.")
        end

        it 'creates a new user on inviting booth responsible' do
          expect(User.where(email: 'user@example.com')).to exist
        end

        it 'does not create a user with invalid email on inviting booth responsible' do
          expect(User.where(email: 'example')).not_to exist
        end

        it 'invited user should be a part of booth responsibles' do
          expect(Booth.last.responsibles.ids).to include(User.find_by(email: 'user@example.com').id)
        end
      end

      context 'create action fails' do
        before { post :create, params: { booth: attributes_for(:booth, title: ''), conference_id: conference.short_title } }

        it 'does not create any record' do
          expected = expect do
            post :create, params: { booth: attributes_for(:booth, title: ''), conference_id: conference.short_title }
          end
          expected.to_not change(Booth, :count)
        end

        it 'redirects to new' do
          expect(response).to render_template('new')
        end

        it 'shows flash message' do
          expect(flash[:error]).to eq("Creating #{t 'booth'} failed. Title can't be blank.")
        end
      end
    end

    describe 'GET #edit' do
      before { get :edit, params: { id: booth.id, conference_id: conference.short_title } }

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end

      it 'assigns booth variable' do
        expect(assigns(:booth)).to eq booth
      end
    end

    describe 'PATCH #update' do
      context 'updates suchessfully' do
        before { patch :update, params: { id: booth.id, booth: attributes_for(:booth, title: 'different', invited_users: 'user@example.com, example'), conference_id: conference.short_title } }
        it 'redirects to admin booth index path' do
          expect(response).to redirect_to admin_conference_booths_path
        end

        it 'shows success message' do
          expect(flash[:notice]).to match "Successfully updated #{t 'booth'}."
        end

        it 'updates booth' do
          booth.reload
          expect(booth.title).to eq('different')
        end

        it 'creates a new user on inviting booth responsible' do
          expect(User.where(email: 'user@example.com')).to exist
        end

        it 'does not create a user with invalid email on inviting booth responsible' do
          expect(User.where(email: 'example')).not_to exist
        end

        it 'invited user should be a part of booth responsibles' do
          booth.reload
          expect(booth.responsibles.ids).to include(User.find_by(email: 'user@example.com').id)
        end
      end
    end
  end
end
