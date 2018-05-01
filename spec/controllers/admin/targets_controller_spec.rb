# frozen_string_literal: true

require 'spec_helper'

describe Admin::TargetsController, type: :controller do
  let(:admin) { create(:admin) }
  let(:conference) { create(:conference) }
  let(:target) { create(:target, conference: conference, target_count: 100) }

  context 'user is admin' do
    before { sign_in admin }

    describe 'GET #index' do
      before { get :index, params: { conference_id: conference.short_title } }

      it 'renders index template' do
        expect(response).to render_template('index')
      end

      it 'assigns targets and conference variables' do
        expect(assigns(:conference)).to eq conference
        expect(assigns(:targets)).to eq [target]
      end
    end

    describe 'GET #new' do
      before { get :new, params: { conference_id: conference.short_title } }

      it 'renders new template' do
        expect(response).to render_template('new')
      end

      it 'assigns target variable' do
        expect(assigns(:target)).to be_instance_of(Target)
      end
    end

    describe 'POST #create' do
      context 'saves successfuly' do
        before do
          post :create, params: { target: attributes_for(:target), conference_id: conference.short_title }
        end

        it 'redirects to admin target index path' do
          expect(response).to redirect_to admin_conference_targets_path(conference_id: conference.short_title)
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Target successfully created.')
        end

        it 'creates new target' do
          expect(Target.count).to eq 1
        end
      end

      context 'save fails' do
        before do
          allow_any_instance_of(Target).to receive(:save).and_return(false)
          post :create, params: { target: attributes_for(:target), conference_id: conference.short_title }
        end

        it 'renders new template' do
          expect(response).to render_template('new')
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Creating target failed: #{target.errors.full_messages.join('. ')}.")
        end

        it 'does not create new target' do
          expect(Target.count).to eq 0
        end
      end
    end

    describe 'GET #edit' do
      before { get :edit, params: { conference_id: conference.short_title, id: target.id } }

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end

      it 'assigns target variable' do
        expect(assigns(:target)).to eq target
      end
    end

    describe 'PATCH #update' do
      context 'updates successfully' do
        before do
          patch :update, params: { target: attributes_for(:target, target_count: 2), conference_id: conference.short_title, id: target.id }
        end

        it 'redirects to admin target index path' do
          expect(response).to redirect_to admin_conference_targets_path(conference_id: conference.short_title)
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Target successfully updated.')
        end

        it 'updates the target' do
          target.reload
          expect(target.target_count).to eq 2
        end
      end

      context 'update fails' do
        before do
          allow_any_instance_of(Target).to receive(:save).and_return(false)
          patch :update, params: { target: attributes_for(:target, target_count: 2), conference_id: conference.short_title, id: target.id }
        end

        it 'renders edit template' do
          expect(response).to render_template('edit')
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Target update failed: #{target.errors.full_messages.join('. ')}.")
        end

        it 'does not update target' do
          expect(target.target_count).to eq 100
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'deletes successfully' do
        before { delete :destroy, params: { conference_id: conference.short_title, id: target.id } }

        it 'redirects to admin target index path' do
          expect(response).to redirect_to admin_conference_targets_path(conference_id: conference.short_title)
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Target successfully destroyed.')
        end

        it 'deletes target' do
          expect(Target.count).to eq 0
        end
      end

      context 'delete fails' do
        before do
          allow_any_instance_of(Target).to receive(:destroy).and_return(false)
          delete :destroy, params: { conference_id: conference.short_title, id: target.id }
        end

        it 'redirects to admin target index path' do
          expect(response).to redirect_to admin_conference_targets_path(conference_id: conference.short_title)
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Could not delete target for #{conference.title}: #{target.errors.full_messages.join('. ')}.")
        end

        it 'does not delete target' do
          expect(Target.count).to eq 1
        end
      end
    end
  end
end
