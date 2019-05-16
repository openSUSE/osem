# frozen_string_literal: true

require 'spec_helper'

describe Admin::EventsController do
  let(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }
  # The where_object() and where_object_changes() methods of paper_trail gem are broken when having:
  # an Event with ID 1, an Event with ID 2, and a commercial with ID 1, for event with ID 2
  # (the numbers could be different as long as there is this matching of IDs).
  # We implemented or own where method to solve this and those ids are for testing this case.
  let!(:event_without_commercial) { create(:event, id: 1, program: conference.program) }
  let!(:event_with_commercial) { create(:event, id: 2, program: conference.program) }
  let!(:event_commercial) { create(:event_commercial, id: 1, commercialable: event_with_commercial, url: 'https://www.youtube.com/watch?v=M9bq_alk-sw') }

  with_versioning do
    describe 'GET #show' do
      before :each do
        sign_in(organizer)
        get :show, params: { id: event_without_commercial.id, conference_id: conference.short_title }
      end

      it 'assigns versions' do
        versions = event_without_commercial.versions
        expect(assigns(:versions)).to eq versions
      end
    end
  end
end
