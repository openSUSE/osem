require 'spec_helper'

describe Admin::EventSchedulesController do
  let(:venue) { create(:venue) }
  let(:conference) { create(:conference, venue: venue) }
  let(:schedule) { create(:schedule, program: conference.program)}
  let(:event_schedule) { create(:event_schedule, schedule: schedule)}
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let(:organizer) { create(:user, role_ids: organizer_role.id) }

  context 'logged in as an organizer' do
    before :each do
      sign_in(organizer)
      event_schedule
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        it 'saves the event schedule to the database' do
          expected = expect do
            post :create, conference_id: conference.short_title, event_schedule:
                 attributes_for(:event_schedule,
                                schedule_id: schedule.id,
                                event_id: create(:event, program: conference.program).id,
                                room_id: create(:room, venue: venue).id,
                                start_time: conference.start_date)
          end
          expected.to change { EventSchedule.count }.by 1
        end

        it 'renders JSON without errors' do
          post :create, conference_id: conference.short_title, event_schedule:
               attributes_for(:event_schedule,
                              schedule_id: schedule.id,
                              event_id: create(:event, program: conference.program).id,
                              room_id: create(:room, venue: venue).id,
                              start_time: conference.start_date)

          expect(response).to be_success
          expect(JSON.parse(response.body)['status']).to eq('ok')
        end
      end

      context 'with invalid attributes' do
        it 'does not save the event schedule to the database' do
          expected = expect do
            post :create, conference_id: conference.short_title, event_schedule:
                 attributes_for(:event_schedule,
                                schedule_id: schedule.id,
                                event_id: nil,
                                room_id: nil,
                                start_time: nil)
          end
          expected.to_not change { EventSchedule.count }
        end

        it 'renders JSON with error' do
          post :create, conference_id: conference.short_title, event_schedule:
               attributes_for(:event_schedule,
                              schedule_id: schedule.id,
                              event_id: nil,
                              room_id: nil,
                              start_time: nil)

          expect(JSON.parse(response.body)['status']).to_not eq('ok')
        end
      end
    end

    describe 'POST #update' do
      context 'with valid attributes' do
        it 'changes event schedule attributes' do
          event = create(:event, program: conference.program)
          room = create(:room, venue: venue)
          patch :update, id: event_schedule.id, conference_id: conference.short_title, event_schedule:
                 attributes_for(:event_schedule,
                                schedule_id: schedule.id,
                                event_id: event.id,
                                room_id: room.id,
                                start_time: conference.start_date)
          event_schedule.reload
          expect(event_schedule.schedule_id).to eq(schedule.id)
          expect(event_schedule.event_id).to eq(event.id)
          expect(event_schedule.room_id).to eq(room.id)
          expect(event_schedule.start_time).to eq(conference.start_date)
        end

        it 'renders JSON without errors' do
          patch :update, id: event_schedule.id, conference_id: conference.short_title, event_schedule:
               attributes_for(:event_schedule,
                              schedule_id: schedule.id,
                              event_id: create(:event, program: conference.program).id,
                              room_id: create(:room, venue: venue).id,
                              start_time: conference.start_date)

          expect(response).to be_success
          expect(JSON.parse(response.body)['status']).to eq('ok')
        end
      end

      context 'with invalid attributes' do
        it 'does not save the event schedule to the database' do
          expected = expect do
            patch :update, id: event_schedule.id, conference_id: conference.short_title, event_schedule:
                 attributes_for(:event_schedule,
                                schedule_id: schedule.id,
                                event_id: nil,
                                room_id: nil,
                                start_time: nil)
          end
          expected.to_not change { event_schedule }
        end

        it 'renders JSON with error' do
          patch :update, id: event_schedule.id, conference_id: conference.short_title, event_schedule:
               attributes_for(:event_schedule,
                              schedule_id: schedule.id,
                              event_id: nil,
                              room_id: nil,
                              start_time: nil)

          expect(JSON.parse(response.body)['status']).to_not eq('ok')
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'deletes the event schedule' do
        expected = expect do
          delete :destroy, id: event_schedule.id, conference_id: conference.short_title
        end

        expected.to change { EventSchedule.count }.by(-1)
      end
      it 'renders JSON without errors' do
        delete :destroy, id: event_schedule.id, conference_id: conference.short_title

        expect(response).to be_success
        expect(JSON.parse(response.body)['status']).to eq('ok')
      end
    end
  end
end
