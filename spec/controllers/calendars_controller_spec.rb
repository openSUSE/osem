# frozen_string_literal: true

require 'spec_helper'

describe CalendarsController do
  render_views

  let!(:conference) { create(:conference, splashpage: create(:splashpage, public: true), venue: create(:venue)) }
  let!(:events) { create_list(:event_scheduled, 2, program: conference.program) }

  describe 'GET #index' do
    before :each do
      conference.program.update(schedule_public: true)
      get :index, format: :ics
    end

    it 'renders a calendar from conference' do
      expect(response.body).to match(/#{conference.title}/im)
    end
  end

  describe 'GET #index with full format' do
    before :each do
      conference.program.update(schedule_public: true)
      get :index, format: :ics, params: { full: 1 }
    end

    it 'renders a calendar from events' do
      expect(response.body).to match(/#{events.first.title}/im)
    end
  end
end
