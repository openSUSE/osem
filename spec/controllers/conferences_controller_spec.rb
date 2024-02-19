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

  describe 'GET#calendar' do
    let(:i_calendar) do
      instance_double(Icalendar::Calendar, publish: true, to_ical: true)
    end
    let!(:conference) { create(:conference) }
    let(:params) { { full: double(:full), format: :ics } }
    let(:user) { create :user, is_admin: true }
    
    setup do
      user.update!(is_admin: true)
      
      sign_in user

      allow(Conference::Calendar::EventBuilder)
        .to receive(:call)

      allow(Icalendar::Calendar)
        .to receive(:new)
        .and_return(i_calendar)
    end

    it 'calls Conference::Calendar::EventBuilder with correct params' do
      expect(Conference::Calendar::EventBuilder)
        .to receive(:call)
        .with(
          conference: conference,
          conference_url: conference_url(conference.short_title),
          calendar: i_calendar,
          is_full_calendar: params[:full].to_s
        )
      
      get :calendar, params: params
    end

    it 'calls calendar#publish' do
      expect(i_calendar).to receive(:publish)

      get :calendar, params: params
    end
  end
end
