# frozen_string_literal: true

require 'spec_helper'

describe SchedulesController do
  let(:conference) { create(:conference, splashpage: create(:splashpage, public: true), venue: create(:venue)) }

  describe 'GET #show' do
    context 'XML' do
      before :each do
        conference.program.schedule_public = true
        conference.program.save!
        create(:event_scheduled, program: conference.program)
        create(:event_scheduled, program: conference.program)

        get :show, params: { conference_id: conference.short_title, format: :xml }
      end

      it 'assigns variables' do
        expect(assigns(:conference)).to eq conference
        expect(assigns(:events_xml)).to eq conference.program.selected_event_schedules.map(&:event)
                                           .group_by{ |event| event.time.to_date }
      end

      it 'has 200 status code' do
        expect(response).to be_success
      end
    end
  end

  describe 'GET #happening_now' do
    let!(:conference2) { create(:full_conference, start_date: 1.day.ago, end_date: 7.days.from_now, start_hour: 0, end_hour: 24) }
    let!(:program) { conference2.program }
    let!(:selected_schedule) { create(:schedule, program: program) }
    let!(:scheduled_event1) do
      program.update_attributes!(selected_schedule: selected_schedule)
      create(:event, program: program, state: 'confirmed', abstract: '`markdown`')
    end
    let!(:event_schedule1) { create(:event_schedule, event: scheduled_event1, schedule: selected_schedule, start_time: Time.now.in_time_zone(conference2.timezone).strftime('%a, %d %b %Y %H:%M:%S')) }
    let!(:scheduled_event2) do
      program.update_attributes!(selected_schedule: selected_schedule)
      create(:event, program: program, state: 'confirmed')
    end
    let!(:event_schedule2) { create(:event_schedule, event: scheduled_event2, schedule: selected_schedule, start_time: (Time.now.in_time_zone(conference2.timezone) + 1.hour).strftime('%a, %d %b %Y %H:%M:%S')) }

    context 'html' do
      before :each do
        get :happening_now, params: { conference_id: conference2.short_title }
      end

      it 'has 200 status code' do
        expect(response).to be_success
      end
    end

    context 'json' do
      before :each do
        get :happening_now, format: :json, params: { conference_id: conference2.short_title }
      end

      it 'has 200 status code' do
        expect(response).to be_success
      end

      it 'returns the events that are happening now' do
        expect(response.body).to include(event_schedule1.to_json(include: :event))
        expect(response.body).not_to include(event_schedule2.to_json(include: :event))
      end

      it 'contains the rendered markdown in HTML of events that are happening now' do
        expect(response.body).to include('code')
      end
    end
  end

  describe 'GET #vertical_schedule' do
    let!(:program) { conference.program }

    context 'as a conference participant' do
      context 'who visits the schedule page' do
        before(:each) do
          get :vertical_schedule, params: { conference_id: conference.short_title }
        end

        it 'returns a successful response' do
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
