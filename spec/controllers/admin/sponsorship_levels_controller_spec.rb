# frozen_string_literal: true

require 'spec_helper'

describe Admin::SponsorshipLevelsController do
  let(:admin) { create(:admin) }
  let(:conference) { create(:conference) }
  let(:sponsorship_level) { create(:sponsorship_level, conference: conference) }

  context 'admin is signed in' do
    before { sign_in admin }

    describe 'GET #index' do
      before { get :index, params: { conference_id: conference.short_title } }

      it 'assigns conference and sponsorship_levels variables' do
        expect(assigns(:conference)).to eq conference
        expect(assigns(:sponsorship_levels)).to eq [sponsorship_level]
      end

      it 'renders index template' do
        expect(response).to render_template('index')
      end
    end

    describe 'GET #edit' do
      before { get :edit, params: { conference_id: conference.short_title, id: sponsorship_level.id } }

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end

      it 'assigns sponsorship_level variable' do
        expect(assigns(:sponsorship_level)).to eq sponsorship_level
      end
    end

    describe 'GET #new' do
      before { get :new, params: { conference_id: conference.short_title } }

      it 'renders new template' do
        expect(response).to render_template('new')
      end

      it 'assigns sponsorship_level variable' do
        expect(assigns(:sponsorship_level)).to be_instance_of(SponsorshipLevel)
      end
    end

    describe 'POST #create' do
      context 'saves successfuly' do
        before(:each, run: true) do
          post :create, params: { sponsorship_level: attributes_for(:sponsorship_level),
                                  conference_id:     conference.short_title }
        end

        it 'redirects to admin sponsorship_level index path', run: true do
          expect(response).to redirect_to admin_conference_sponsorship_levels_path(conference_id: conference.short_title)
        end

        it 'shows success message in flash notice', run: true do
          expect(flash[:notice]).to match('Sponsorship level successfully created.')
        end

        it 'creates new sponsorship_level' do
          expect do
            post :create, params: { sponsorship_level: attributes_for(:sponsorship_level),
                                    conference_id:     conference.short_title }
          end.to change{ conference.sponsorship_levels.count }.from(0).to(1)
        end
      end

      context 'save fails' do
        before do
          allow_any_instance_of(SponsorshipLevel).to receive(:save).and_return(false)
          post :create, params: { sponsorship_level: attributes_for(:sponsorship_level),
                                  conference_id:     conference.short_title }
        end

        it 'renders new template' do
          expect(response).to render_template('new')
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Creating Sponsorship Level failed: #{sponsorship_level.errors.full_messages.join('. ')}.")
        end

        it 'does not create new sponsorship_level' do
          expect(SponsorshipLevel.count).to eq 0
        end
      end
    end

    describe 'PATCH #update' do
      context 'updates successfully' do
        before do
          patch :update, params: { sponsorship_level: attributes_for(:sponsorship_level, title: 'Gold'),
                                   conference_id:     conference.short_title,
                                   id:                sponsorship_level.id }
        end

        it 'redirects to admin sponsorship_level index path' do
          expect(response).to redirect_to admin_conference_sponsorship_levels_path(conference_id: conference.short_title)
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Sponsorship level successfully updated.')
        end

        it 'updates the sponsorship_level' do
          sponsorship_level.reload
          expect(sponsorship_level.title).to eq 'Gold'
        end
      end

      context 'update fails' do
        before do
          allow_any_instance_of(SponsorshipLevel).to receive(:save).and_return(false)
          patch :update, params: { sponsorship_level: attributes_for(:sponsorship_level, title: 'Gold'),
                                   conference_id:     conference.short_title,
                                   id:                sponsorship_level.id }
        end

        it 'renders edit template' do
          expect(response).to render_template('edit')
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Update Sponsorship level failed: #{sponsorship_level.errors.full_messages.join('. ')}.")
        end

        it 'does not update sponsorship_level' do
          sponsorship_level.reload
          expect(sponsorship_level.title).not_to eq 'Gold'
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'deletes successfully' do
        before(:each, run: true) do
          delete :destroy, params: { conference_id: conference.short_title, id: sponsorship_level.id }
        end

        it 'redirects to admin sponsorship_level index path', run: true do
          expect(response).to redirect_to admin_conference_sponsorship_levels_path(conference_id: conference.short_title)
        end

        it 'shows success message in flash notice', run: true do
          expect(flash[:notice]).to match('Sponsorship level successfully deleted.')
        end

        it 'deletes the sponsorship_level' do
          sponsorship_level
          expect do
            delete :destroy, params: { conference_id: conference.short_title, id: sponsorship_level.id }
          end.to change{ conference.sponsorship_levels.count }.from(1).to(0)
        end
      end

      context 'delete fails' do
        before do
          allow_any_instance_of(SponsorshipLevel).to receive(:destroy).and_return(false)
          delete :destroy, params: { conference_id: conference.short_title, id: sponsorship_level.id }
        end

        it 'redirects to admin sponsorship_level index path' do
          expect(response).to redirect_to admin_conference_sponsorship_levels_path(conference_id: conference.short_title)
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Deleting sponsorship level failed! #{sponsorship_level.errors.full_messages.join('. ')}.")
        end

        it 'does not delete sponsorship_level' do
          expect(conference.sponsorship_levels.count).to eq 1
        end
      end
    end

    describe 'PATCH #up' do
      before do
        sponsorship_level
        @second_sponsorship_level = create(:sponsorship_level, conference: conference)
        patch :up, params: { conference_id: conference.short_title, id: @second_sponsorship_level.id }
      end

      it 'moves sponsorship_level up by one position' do
        sponsorship_level.reload
        @second_sponsorship_level.reload
        expect(sponsorship_level.position).to eq 2
        expect(@second_sponsorship_level.position).to eq 1
      end
    end

    describe 'PATCH #down' do
      before do
        sponsorship_level
        @second_sponsorship_level = create(:sponsorship_level, conference: conference)
        patch :down, params: { conference_id: conference.short_title, id: sponsorship_level.id }
      end

      it 'moves sponsorship_level down by one position' do
        sponsorship_level.reload
        @second_sponsorship_level.reload
        expect(sponsorship_level.position).to eq 2
        expect(@second_sponsorship_level.position).to eq 1
      end
    end
  end
end
