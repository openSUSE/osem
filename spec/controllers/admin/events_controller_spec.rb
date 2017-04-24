require 'spec_helper'

describe Admin::EventsController do
  let(:conference) { create(:conference) }
  let(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let(:organizer) { create(:user, role_ids: organizer_role.id) }
  let!(:event_without_commercial) { create(:event, program: conference.program) }
  let!(:event_with_commercial) { create(:event, program: conference.program) }
  let!(:event_commercial) { create(:event_commercial, commercialable: event_with_commercial, url: 'https://www.youtube.com/watch?v=M9bq_alk-sw') }

  with_versioning do
    describe 'GET #show' do
      before :each do
        sign_in(organizer)
        get :show, id: event_without_commercial.id, conference_id: conference.short_title
      end

      it 'assigns versions' do
        versions = event_without_commercial.versions
        expect(event_without_commercial.id).to eq event_commercial.id
        expect(event_commercial.id).not_to eq event_commercial.commercialable_id
        expect(assigns(:versions)).to eq versions
      end
    end
  end
end
