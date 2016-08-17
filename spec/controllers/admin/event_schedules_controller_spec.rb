require 'spec_helper'

describe Admin::EventSchedulesController do
  let(:venue) { create(:venue) }
  let(:conference) { create(:conference, venue: venue) }
  let(:room) { create(:room, venue: venue) }
  let(:schedule) { create(:schedule, program: conference.program) }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let(:organizer) { create(:user, role_ids: organizer_role.id) }

  context 'logged in as an organizer' do
    before :each do
      sign_in(organizer)
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        let(:event1) { create(:event, program: conference.program) }
        let(:event2) { create(:event, program: conference.program) }
        let(:create_action) do
          post :bulk_create, conference_id: conference.short_title,
                             event_schedules: {
                               event1.id => {
                                 schedule_id: schedule.id,
                                 event_id: event1.id,
                                 room_id: create(:room, venue: venue).id,
                                 start_time: conference.start_date
                               },
                               event2.id => {
                                 schedule_id: schedule.id,
                                 event_id: event2.id,
                                 room_id: create(:room, venue: venue).id,
                                 start_time: conference.start_date
                               }
                             }
        end

        it 'saves the event schedule to the database' do
          expect{ create_action }.to change { EventSchedule.count }.by 2
        end

        it 'has 200 status code' do
          create_action
          expect(response).to be_success
        end
      end

      context 'with invalid attributes' do
        let(:event1) { create(:event, program: conference.program) }
        let(:create_action) do
          post :bulk_create, conference_id: conference.short_title,
                             event_schedules: {
                               event1.id => {
                                 schedule_id: schedule.id,
                                 event_id: event1.id,
                                 room_id: nil,
                                 start_time: nil
                               }
                             }
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
        let(:event1) { create(:event, program: conference.program) }
        let(:event2) { create(:event, program: conference.program) }
        let(:event_schedule1) { create(:event_schedule, schedule: schedule, event: event1) }
        let(:event_schedule2) { create(:event_schedule, schedule: schedule, event: event2) }
        before :each do
          post :bulk_update, conference_id: conference.short_title,
                             event_schedules: {
                               event1.id => {
                                 event_schedule1.id => {
                                   room_id: room.id,
                                   start_time: conference.start_date
                                 }
                               },
                               event2.id => {
                                 event_schedule2.id => {
                                   room_id: room.id,
                                   start_time: conference.start_date + 1.day
                                 }
                               }
                             }
          event_schedule1.reload
          event_schedule2.reload
        end

        it 'updates the room' do
          expect(event_schedule1.room_id).to eq(room.id)
          expect(event_schedule2.room_id).to eq(room.id)
        end

        it 'updates the start_time' do
          expect(event_schedule1.start_time).to eq(conference.start_date)
          expect(event_schedule2.start_time).to eq(conference.start_date + 1.day)
        end

        it 'has 200 status code' do
          expect(response).to be_success
        end
      end

      context 'with invalid attributes' do
        let(:event) { create(:event, program: conference.program) }
        let(:event_schedule) { create(:event_schedule, schedule: schedule, event: event) }
        let(:update_action) do
          post :bulk_update, conference_id: conference.short_title,
                             event_schedules: {
                               event.id => {
                                 event_schedule.id => {
                                   room_id: nil,
                                   start_time: nil
                                 }
                               }
                             }
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
      let(:event1) { create(:event, program: conference.program) }
      let(:event2) { create(:event, program: conference.program) }
      let(:event_schedule1) { create(:event_schedule, schedule: schedule, event: event1) }
      let(:event_schedule2) { create(:event_schedule, schedule: schedule, event: event2) }
      let(:destroy_action) do
        post :bulk_destroy, conference_id: conference.short_title,
                            event_schedules: {
                              event1.id => event_schedule1,
                              event2.id => event_schedule2
                            }
      end

      it 'deletes the event schedule' do
        event_schedule1.reload
        event_schedule2.reload
        expect{ destroy_action }.to change { EventSchedule.count }.by(-2)
      end

      it 'has 200 status code' do
        destroy_action
        expect(response).to be_success
      end
    end
  end
end
