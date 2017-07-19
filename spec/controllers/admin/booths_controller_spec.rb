require 'spec_helper'

describe Admin::BoothsController do

  let(:admin) { create(:admin) }
  let(:conference) { create(:conference) }
  let(:booth) { create(:booth, conference: conference) }
  let(:admin) { create(:admin) }

  context 'not logged in user' do

    describe 'GET index' do
      it 'does not render admin/booths#index' do
        get :index, conference_id: conference.short_title
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe 'GET show' do
      it 'does not render admin/booths#show' do
        get :show, id: booth.id, conference_id: conference.short_title
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  context 'user is admin' do
    before :each do
      sign_in admin
    end

    describe 'GET index' do
      before { get :index, conference_id: conference.short_title }

      it 'assigns attributes for booths' do
        expect(assigns(:booths)).to eq([booth])
      end

      it 'renders index template' do
        expect(response).to render_template('index')
      end
    end

    describe 'GET new' do
      before { get :new, conference_id: conference.short_title }

      it 'assigns attributes for booths' do
        expect(assigns(:booth)).to be_a_new(Booth)
      end

      it 'renders new template' do
        expect(response).to render_template('new')
      end
    end

    describe 'POST #create' do
      context 'successfully created' do
      #   it 'creates a new booth' do
      #     expected = expect do
      #       post :create, booth: attributes_for(:booth), conference_id: conference.short_title
      #     end
      #     expected.to change { Booth.count }.by(1)
      #   end
      #
        # it 'redirects to admin booth index' do
        #   post :create, booth: attributes_for(:booth), conference_id: conference.short_title
        #   expect(response).to redirect_to(admin_conference_booths_path)
        # end
      #
        # it 'has responsibles' do
        #   post :create, booth: attributes_for(:booth), conference_id: conference.short_title
        #   expect(booth.responsibles.count).to eq(0)
        # end

        it 'shows success message' do
          post :create, booth: attributes_for(:booth), conference_id: conference.short_title
          expect(flash[:error]).to match('Booth successfully created.')
        end
      end

      context 'create action fails' do
        it 'does not create any record' do
          expected = expect do
            post :create, booth: attributes_for(:booth, title: ''), conference_id: conference.short_title
          end
          expected.to_not change(Booth, :count)
        end

        it 'redirects to new' do
          post :create, booth: attributes_for(:booth, title: ''), conference_id: conference.short_title

          expect(response).to render_template('new')
        end

        # it 'shows flash message' do
        #   post :create, booth: attributes_for(:booth, title: ''), conference_id: conference.short_title
        #
        #   expect(flash[:error]).to eq("Title can't be blank")
        # end
      end
    end

    describe 'PATCH #update' do
      context 'updates suchessfully' do
        it 'redirects to admin booth index path' do
          patch :update, id: booth.id, booth: attributes_for(:booth, title: 'different'), conference_id: conference.short_title
          expect(response).to redirect_to admin_conference_booths_path
        end

        it 'shows success message' do
          patch :update, id: booth.id, booth: attributes_for(:booth, title: 'different'), conference_id: conference.short_title
          expect(flash[:notice]).to match"Successfully updated booth."
        end

        it 'updates booth' do
          patch :update, id: booth.id, booth: attributes_for(:booth, title: 'different'), conference_id: conference.short_title
          booth.reload
          expect(booth.title).to eq('different')
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'deletes successfully' do
        # it 'booth deleted' do
        #   expected = expect do
        #     delete :destroy, id: booth.id, conference_id: conference.short_title
        #   end
        #   expected.to change { Booth.count }.by(-1)
        # end

        it 'redirects to admin booth index path' do
          delete :destroy, id: booth.id, conference_id: conference.short_title
          expect(response).to redirect_to(admin_conference_booths_path)
        end

        it 'show success message' do
          delete :destroy, id: booth.id, conference_id: conference.short_title
          expect(flash[:notice]).to match('Booth successfully destroyed.')
        end
      end
    end

    describe 'GET #edit' do
      it 'renders edit template' do
        get :edit, id: booth.id, conference_id: conference.short_title
        expect(response).to render_template('edit')
      end

      it 'assigns booth variable' do
        get :edit, id: booth.id, conference_id: conference.short_title
        expect(assigns(:booth)).to eq booth
      end
    end

  end
end
