require 'pry'

# frozen_string_literal: true

require 'spec_helper'

describe Admin::CfpsController do
  let!(:today) { Date.today }
  let!(:conference) { create(:conference, start_date: today + 20.days, end_date: today + 30.days) }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, role_ids: organizer_role.id) }
  let(:cfp) { create(:cfp, program: conference.program) }

  before { sign_in(organizer) }

  describe 'POST #create' do
    it 'successes' do
      post :create, conference_id: conference.short_title, cfp: { cfp_type: 'events', start_date: today, end_date: today + 6.days, description: 'We call for papers, or tabak, or you know what!' }
      expect(flash[:notice]).to match('Call for papers successfully created.')
    end
  end

  describe 'POST #update' do
    it 'successes' do
      patch :update, conference_id: conference.short_title, id: cfp.id, cfp: { end_date: today + 10.days }
      expect(flash[:notice]).to match('Call for papers successfully updated.')
    end
  end
end
