require 'spec_helper'

describe Admin::EventsRegistrationsController do

  let(:conference) { create(:conference) }
  let(:user_organizer) { create(:user, role_ids: [Role.find_by(name: 'organizer', resource: conference).id]) }
  let(:user_cfp) { create(:user, role_ids: [Role.find_by(name: 'cfp', resource: conference).id]) }
  let(:user) { create(:user) }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:submitter1) { create(:user) }
  let(:submitter2) { create(:user) }
  let(:registration1) { create(:registration, user: user1, conference: conference) }
  let(:registration2) { create(:registration, user: user2, conference: conference) }
  let!(:event_of_submitter1) do
    create(:event, program: conference.program,
                   require_registration: true,
                   max_attendees: 3,
                   users: [submitter1])
  end
  let!(:event_of_submitter2) { create(:event, program: conference.program, users: [submitter2]) }
  let(:event_other) { create(:event) }
  let!(:events_registration1) do
    create(:events_registration,
           event: event_of_submitter1,
           registration: registration1,
           attended: false)
  end

  let!(:events_registration2) do
    create(:events_registration,
           event: event_of_submitter2,
           registration: registration2,
           attended: false)
  end

  shared_examples 'access allowed' do
    describe 'GET #show' do
      before :each do
        get :show, conference_id: conference.short_title, event_id: event_of_submitter1.id
      end

      it 'renders show template' do
        expect(response).to render_template :show
      end
    end

    describe 'PATCH #toggle' do
      it 'unregisters user from event' do
        event_of_submitter1.registrations = [registration1]
        event_of_submitter1.save!
        patch :toggle, conference_id: conference.short_title,
                       event_id: event_of_submitter1.id,
                       registration_id: registration1.id,
                       state: 'false', format: 'js'
        event_of_submitter1.reload
        expect(event_of_submitter1.registrations).to eq []
      end

      it 'registers user to event' do
        event_of_submitter1.registrations = []
        event_of_submitter1.save!

        patch :toggle, conference_id: conference.short_title,
                       event_id: event_of_submitter1.id,
                       registration_id: registration1.id,
                       state: 'true', format: 'js'
        event_of_submitter1.reload
        expect(event_of_submitter1.registrations).to eq [registration1]
      end
    end

    describe 'PATCH #toggle_attendance' do
      it 'marks registered user as present' do
        events_registration1.attended = false
        events_registration1.save!
        patch :toggle_attendance, conference_id: conference.short_title,
                                  event_id: event_of_submitter1.id,
                                  registration_id: registration1.id, format: 'js'

        events_registration1.reload
        expect(events_registration1.attended).to eq true
      end

      it 'marks registered user as absent' do
        events_registration1.attended = true
        events_registration1.save!
        patch :toggle_attendance, conference_id: conference.short_title,
                                  event_id: event_of_submitter1.id,
                                  registration_id: registration1.id, format: 'js'
        events_registration1.reload
        expect(events_registration1.attended).to eq false
      end
    end
  end

  shared_examples 'access not allowed' do |path|
    describe 'GET #show' do
      before :each do
        get :show, conference_id: conference.short_title, event_id: event_of_submitter1.id
      end

      it 'redirects to root path' do
        expect(response).to redirect_to send(path)
      end
    end

    describe 'PATCH #toggle' do
      it 'does not register user to event' do
        event_of_submitter1.registrations = []
        event_of_submitter1.save!

        patch :toggle, conference_id: conference.short_title,
                       event_id: event_of_submitter1.id,
                       registration_id: registration1.id,
                       state: 'true', format: 'js'

        expect(event_of_submitter1.registrations).to eq []
      end

      it 'does not unregister user from event' do
        patch :toggle, conference_id: conference.short_title,
                       event_id: event_of_submitter1.id,
                       registration_id: registration1.id,
                       state: 'false', format: 'js'
        expect(event_of_submitter1.registrations).to eq [registration1]
      end
    end

    describe 'PATCH #toggle_attendance' do
      it 'does not mark registered user as present' do
        events_registration1.attended = false
        events_registration1.save!
        patch :toggle_attendance, conference_id: conference.short_title,
                                  event_id: event_of_submitter1.id,
                                  registration_id: registration1.id, format: 'js'
        expect(events_registration1.attended).to eq false
      end

      it 'does not mark registered user as absent' do
        events_registration1.attended = true
        events_registration1.save!
        patch :toggle_attendance, conference_id: conference.short_title,
                                  event_id: event_of_submitter1.id,
                                  registration_id: registration1.id, format: 'js'
        expect(events_registration1.attended).to eq true
      end
    end
  end

  describe 'organizer access' do
    before(:each) do
      sign_in user_organizer
    end

    it_behaves_like 'access allowed'
  end

  describe 'cfp access' do
    before(:each) do
      sign_in user_cfp
    end

    it_behaves_like 'access allowed'
  end

  describe 'submitter access' do
    before(:each) do
      sign_in submitter1
    end

    it_behaves_like 'access not allowed', :root_path
  end

  describe 'without user access' do
    it_behaves_like 'access not allowed', :new_user_session_path
  end
end
