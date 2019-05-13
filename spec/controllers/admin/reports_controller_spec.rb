# frozen_string_literal: true

require 'spec_helper'

describe Admin::ReportsController do

  let(:conference) { create(:conference, start_date: Date.current - 1.day) }
  let!(:admin) { create(:admin) }
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:venue) { create(:venue, conference: conference) }
  let!(:room) { create(:room, venue: venue) }
  let!(:track_submitter) { create(:user) }
  let!(:self_organized_track) { create(:track, :self_organized, submitter_id: track_submitter.id, program: conference.program, name: 'My awesome track', start_date: Date.current, end_date: Date.current, room: room, state: 'confirmed') }
  let!(:track) { create(:track, program: conference.program, color: '#800080') }

  let!(:event1) { create(:event, id: 1, program: conference.program, track: self_organized_track, speakers: [user1], state: 'confirmed') }
  let!(:event2) { create(:event, id: 2, program: conference.program, track: track, speakers: [user2], state: 'confirmed') }

  context 'track organizer is signed in' do
    before :each do
      sign_in(track_submitter)
      self_organized_track.assign_role_to_submitter
    end

    describe 'GET #index' do
      it 'renders the index template' do
        get :index, params: { conference_id: conference.short_title }
        expect(response).to render_template :index
      end

      it 'initialises missing speakers' do
        get :index, params: { conference_id: conference.short_title }
        expect(assigns(:missing_event_speakers).pluck(:user_id)).to eq [user1.id]
      end
    end
  end
end
