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
    before do
      @conference2 = create(:full_conference, start_date: 1.day.ago, end_date: 7.days.from_now, start_hour: 0, end_hour: 24)
      @program = @conference2.program
      @selected_schedule = create(:schedule, program: @program)
      @program.update_attributes!(selected_schedule: @selected_schedule)
      @scheduled_event1 = create(:event, program: @program, state: 'confirmed')
      @event_schedule1 = create(:event_schedule, event: @scheduled_event1, schedule: @selected_schedule, start_time: Time.now)
      @scheduled_event2 = create(:event, program: @program, state: 'confirmed')
      @event_schedule2 = create(:event_schedule, event: @scheduled_event2, schedule: @selected_schedule, start_time: Time.now + 1.hour)
    end
    
    context 'html' do
      before :each do
        get :happening_now, params: { conference_id: @conference2.short_title }
      end

      it 'has 200 status code' do
        expect(response).to be_success
      end
    end

    context 'json' do
      before :each do
        get :happening_now, format: :json, params: { conference_id: @conference2.short_title }
      end
      
      it 'has 200 status code' do
        expect(response).to be_success
      end

      it 'returns the events that are happening now' do
        expect(response.body).to include(@event_schedule1.to_json)
        expect(response.body).not_to include(@event_schedule2.to_json)
      end
    end
  end
end
