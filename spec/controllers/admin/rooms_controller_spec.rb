# frozen_string_literal: true

require 'spec_helper'

describe Admin::RoomsController do
  let!(:admin) { create(:admin) }
  let(:conference) { create(:conference) }
  let!(:venue) { create(:venue, conference: conference) }
  let(:room) { create(:room, venue: venue, size: 4) }

  context 'admin is signed in' do
    before { sign_in admin }

    describe 'GET #index' do
      before { get :index, params: { conference_id: conference.short_title } }

      it 'assigns conference, venue and rooms variables' do
        expect(assigns(:conference)).to eq conference
        expect(assigns(:venue)).to eq venue
        expect(assigns(:rooms)).to eq [room]
      end

      it 'renders index template' do
        expect(response).to render_template('index')
      end
    end

    describe 'GET #edit' do
      before { get :edit, params: { conference_id: conference.short_title, id: room.id } }

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end

      it 'assigns room variable' do
        expect(assigns(:room)).to eq room
      end
    end

    describe 'GET #new' do
      before { get :new, params: { conference_id: conference.short_title } }

      it 'renders new template' do
        expect(response).to render_template('new')
      end

      it 'assigns room variable' do
        expect(assigns(:room)).to be_instance_of(Room)
      end
    end

    describe 'POST #create' do
      context 'saves successfuly' do
        before do
          post :create, params: { room: attributes_for(:room), conference_id: conference.short_title }
        end

        it 'redirects to admin room index path' do
          expect(response).to redirect_to admin_conference_venue_rooms_path(conference_id: conference.short_title)
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Room successfully created.')
        end

        it 'creates new room' do
          expect(Room.count).to eq 1
        end
      end

      context 'save fails' do
        before do
          allow_any_instance_of(Room).to receive(:save).and_return(false)
          post :create, params: { room: attributes_for(:room), conference_id: conference.short_title }
        end

        it 'renders new template' do
          expect(response).to render_template('new')
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Creating Room failed: #{room.errors.full_messages.join('. ')}.")
        end

        it 'does not create new room' do
          expect(Room.count).to eq 0
        end
      end
    end

    describe 'PATCH #update' do
      context 'updates successfully' do
        before do
          patch :update, params: { room:          attributes_for(:room, size: 2),
                                   conference_id: conference.short_title,
                                   id:            room.id }
        end

        it 'redirects to admin room index path' do
          expect(response).to redirect_to admin_conference_venue_rooms_path(conference_id: conference.short_title)
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Room successfully updated.')
        end

        it 'updates the room' do
          room.reload
          expect(room.size).to eq 2
        end
      end

      context 'update fails' do
        before do
          allow_any_instance_of(Room).to receive(:save).and_return(false)
          patch :update, params: { room:          attributes_for(:room, size: 2),
                                   conference_id: conference.short_title,
                                   id:            room.id }
        end

        it 'renders edit template' do
          expect(response).to render_template('edit')
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Update Room failed: #{room.errors.full_messages.join('. ')}.")
        end

        it 'does not update room' do
          room.reload
          expect(room.size).to eq 4
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'deletes successfully' do
        before { delete :destroy, params: { conference_id: conference.short_title, id: room.id } }

        it 'redirects to admin room index path' do
          expect(response).to redirect_to admin_conference_venue_rooms_path(conference_id: conference.short_title)
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Room successfully deleted.')
        end

        it 'deletes the room' do
          expect(Room.count).to eq 0
        end
      end

      context 'delete fails' do
        before do
          allow_any_instance_of(Room).to receive(:destroy).and_return(false)
          delete :destroy, params: { conference_id: conference.short_title, id: room.id }
        end

        it 'redirects to admin room index path' do
          expect(response).to redirect_to admin_conference_venue_rooms_path(conference_id: conference.short_title)
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Destroying room failed! #{room.errors.full_messages.join('. ')}.")
        end

        it 'does not delete room' do
          expect(Room.count).to eq 1
        end
      end
    end
  end
end
