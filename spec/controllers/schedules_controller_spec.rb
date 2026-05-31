# frozen_string_literal: true

require 'spec_helper'

describe SchedulesController do
  let(:conference) { create(:conference, splashpage: create(:splashpage, public: true), venue: create(:venue)) }

  describe 'GET #show' do
    before :each do
      conference.program.update!(schedule_public: true)
      create_pair(:event_scheduled, program: conference.program)
    end

    context 'XML' do
      before :each do
        get :show, params: { conference_id: conference.short_title, format: :xml }
      end

      it 'assigns variables' do
        expect(assigns(:conference)).to eq conference
        expect(assigns(:events_xml)).to eq conference.program.selected_event_schedules.map(&:event)
                                           .group_by{ |event| event.time.to_date }
      end

      it 'has 200 status code' do
        expect(response).to be_successful
      end
    end

    context 'iCalendar' do
      before :each do
        get :show, params: { conference_id: conference.short_title, format: :ics }
      end

      it 'has 200 status code' do
        expect(response).to be_successful
      end

      it 'returns iCalendar data' do
        expect(response.content_type).to start_with('text/calendar')
        expect(response.body).to start_with('BEGIN:VCALENDAR')
      end
    end
  end
end
