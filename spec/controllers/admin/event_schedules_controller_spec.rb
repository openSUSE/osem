# frozen_string_literal: true

require 'spec_helper'

describe Admin::EventSchedulesController do
  let(:venue) { create(:venue) }
  let(:conference) { create(:conference, venue: venue) }
  let(:room) { create(:room, venue: venue) }
  let(:schedule) { create(:schedule, program: conference.program)}
  let(:event_schedule) { create(:event_schedule, schedule: schedule)}
  let!(:organizer) { create(:organizer, resource: conference) }

  context 'logged in as an organizer' do
    before :each do
      sign_in(organizer)
      event_schedule
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        let(:create_action) do
          post :create, params: { conference_id: conference.short_title, event_schedule:
               attributes_for(:event_schedule,
                              schedule_id: schedule.id,
                              event_id:    create(:event, program: conference.program).id,
                              room_id:     create(:room, venue: venue).id,
                              start_time:  conference.start_date + conference.start_hour.hours) }
        end

        it 'saves the event schedule to the database' do
          expect{ create_action }.to change { EventSchedule.count }.by 1
        end

        it 'has 200 status code' do
          create_action
          expect(response).to be_successful
        end
      end

      context 'with invalid attributes' do

        let(:create_action) do
          post :create, params: { conference_id: conference.short_title, event_schedule:
               attributes_for(:event_schedule,
                              schedule_id: schedule.id,
                              event_id:    nil,
                              room_id:     nil,
                              start_time:  nil) }
        end

        it 'does not save the event schedule to the database' do
          expect{ create_action }.to_not change { EventSchedule.count }
        end

        it 'has 422 status code' do
          create_action
          expect(response.status).to eq(422)
        end
      end
    end

    describe 'POST #update' do
      context 'with valid attributes' do
        before :each do
          patch :update, params: { id: event_schedule.id, conference_id: conference.short_title, event_schedule:
                 attributes_for(:event_schedule,
                                schedule_id: schedule.id,
                                event_id:    create(:event, program: conference.program).id,
                                room_id:     room.id,
                                start_time:  conference.start_date + conference.start_hour.hours) }
          event_schedule.reload
        end

        it 'updates the room' do
          expect(event_schedule.room_id).to eq(room.id)
        end

        it 'updates the start_time' do
          expect(event_schedule.start_time).to eq(conference.start_date + conference.start_hour.hours)
        end

        it 'has 200 status code' do
          expect(response).to be_successful
        end
      end

      context 'with invalid attributes' do
        let(:update_action) do
          patch :update, params: { id: event_schedule.id, conference_id: conference.short_title, event_schedule:
               attributes_for(:event_schedule,
                              schedule_id: schedule.id,
                              event_id:    nil,
                              room_id:     nil,
                              start_time:  nil) }
        end
        it 'does not save the event schedule to the database' do
          expect{ update_action }.to_not change { event_schedule }
        end

        it 'has 422 status code' do
          update_action
          expect(response.status).to eq(422)
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:destroy_action) do
        delete :destroy, params: { id: event_schedule.id, conference_id: conference.short_title }
      end

      it 'deletes the event schedule' do
        expect{ destroy_action }.to change { EventSchedule.count }.by(-1)
      end

      it 'has 200 status code' do
        destroy_action
        expect(response).to be_successful
      end
    end
  end
end
