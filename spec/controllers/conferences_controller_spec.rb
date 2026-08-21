# frozen_string_literal: true

require 'spec_helper'

describe ConferencesController do
  let(:conference) { create(:conference, splashpage: create(:splashpage, public: true), venue: create(:venue)) }
  let!(:cfp) { create(:cfp, program: conference.program) }
  let(:room) { create(:room, venue: conference.venue) }

  describe 'GET #index' do
    it 'Response code is 200' do
      get :index
      expect(response.response_code).to eq(200)
    end
  end

  describe 'GET #show' do
    context 'conference made public' do
      it 'assigns the requested conference to conference' do
        get :show, params: { id: conference.short_title }
        expect(assigns(:conference)).to eq conference
      end

      it 'renders the show template' do
        get :show, params: { id: conference.short_title }
        expect(response).to render_template :show
      end
    end

    context 'accessing conference via custom domain' do
      before do
        conference.update_attribute(:custom_domain, 'lvh.me')
        @request.host = 'lvh.me'
      end

      it 'assigns correct conference' do
        get :show

        expect(response).to render_template :show
        expect(assigns(:conference)).to eq conference
      end
    end
  end

  describe 'OPTIONS #index' do
    it 'Response code is 200' do
      process :index
      expect(response.response_code).to eq(200)
    end
  end

  describe 'GET #calendar' do
    it 'returns iCalendar data for all conferences' do
      get :calendar, params: { format: :ics }

      expect(response).to be_successful
      expect(response.content_type).to start_with('text/calendar')
      expect(response.body).to start_with('BEGIN:VCALENDAR')
    end

    it 'returns iCalendar data with full schedule when full=true' do
      conference.program.update!(schedule_public: true)
      create(:event_scheduled, program: conference.program)

      get :calendar, params: { full: true, format: :ics }

      expect(response).to be_successful
      expect(response.content_type).to start_with('text/calendar')
      expect(response.body).to start_with('BEGIN:VCALENDAR')
    end
  end

end
