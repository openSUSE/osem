# frozen_string_literal: true

require 'spec_helper'

describe BoothsController do

  let(:user) { create(:user) }
  let(:conference) { create(:conference) }
  let(:booth) { create(:booth, title: 'Title', conference: conference) }

  context 'user is signed in with submitter role' do
    before :each do
      create(:cfp, program: conference.program, cfp_type: 'booths')
      sign_in booth.submitter
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

    describe 'GET #new' do
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
          expect(Booth.count).to_not eq(0)
        end

        it 'redirects to booth index' do
          expect(response).to redirect_to(conference_booths_path)
        end

        it 'has responsibles' do
          expect(booth.responsibles.count).to_not eq(0)
        end

        it 'shows success message' do
          expect(flash[:notice]).to match("#{(t 'booth').capitalize} successfully created.")
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
        before { patch :update, params: { id: booth.id, booth: attributes_for(:booth, title: 'different'), conference_id: conference.short_title } }

        it 'redirects to booth index path' do
          expect(response).to redirect_to conference_booths_path
        end

        it 'shows success message' do
          expect(flash[:notice]).to match 'Booth successfully updated!'
        end

        it 'updates booth' do
          booth.reload
          expect(booth.title).to eq('different')
        end
      end
    end
  end
end
