require 'spec_helper'
require 'cancan/matchers'

describe 'User' do
  describe 'Abilities' do
    # automatically becomes admin
    let!(:first_user) { create(:user) }

    # see https://github.com/CanCanCommunity/cancancan/wiki/Testing-Abilities
    subject(:ability){ Ability.new(user) }
    let(:user){ nil }

    let(:conference_not_public) { create(:conference, splashpage: create(:splashpage, public: false)) }
    let(:conference_public) { create(:conference, splashpage: create(:splashpage, public: true), call_for_paper: create(:call_for_paper, schedule_public: true)) }

    let(:event_confirmed) { create(:event, state: 'confirmed') }
    let(:event_unconfirmed) { create(:event) }

    let(:commercial_event_confirmed) { create(:commercial, commercialable: event_confirmed) }
    let(:commercial_event_unconfirmed) { create(:commercial, commercialable: event_unconfirmed) }

    let(:registration) { create(:registration) }

    # Test abilities for not signed in users
    context 'when user is not signed in' do
      it{ should be_able_to(:index, Conference)}

      it{ should be_able_to(:show, conference_public)}
      it{ should_not be_able_to(:show, conference_not_public)}

      it{ should be_able_to(:schedule, conference_public)}
      it{ should_not be_able_to(:schedule, conference_not_public)}

      it{ should be_able_to(:show, event_confirmed)}
      it{ should_not be_able_to(:show, event_unconfirmed)}

      it{ should be_able_to(:show, commercial_event_confirmed)}
      it{ should_not be_able_to(:show, commercial_event_unconfirmed)}

      it{ should be_able_to(:show, User)}

      it{ should be_able_to(:create, Registration)}
      it{ should be_able_to(:show, Registration.new)}
      it{ should_not be_able_to(:manage, registration)}

      it{ should_not be_able_to(:manage, :any)}
    end

    # Test abilities for signed in users (without any role)
    context 'when user is a Signed In User' do
      let(:user) { create(:user) }
      let(:user2) { create(:user) }
      let(:subscription) { create(:subscription, user: user) }
      let(:registration_public) { create(:registration, conference: conference_public, user: user) }
      let(:registration_not_public) { create(:registration, conference: conference_not_public, user: user) }

      let(:my_event) { create(:event, users: [user]) }

      let(:commercial) { create(:commercial, commercialable: event_unconfirmed) }
      let(:my_commercial) { create(:commercial, commercialable: my_event) }

      it{ should be_able_to(:manage, user) }

      it{ should be_able_to(:manage, registration_public) }
      it{ should be_able_to(:manage, registration_not_public) }

      it{ should be_able_to(:index, Ticket) }
      it{ should be_able_to(:manage, TicketPurchase.new(user_id: user.id)) }

      it{ should be_able_to(:create, Subscription.new(user_id: user.id)) }
      it{ should be_able_to(:destroy, subscription) }

      it{ should be_able_to(:create, Event) }
      it{ should be_able_to(:manage, my_event) }
      it{ should_not be_able_to(:manage, event_unconfirmed) }

      it{ should be_able_to(:create, my_event.commercials.new) }
      it{ should be_able_to(:manage, my_commercial) }
      it{ should_not be_able_to(:manage, commercial) }
    end

    context 'user #is_admin?' do
      let(:user) { create(:admin) }
      it{ should be_able_to(:manage, :all) }
    end

    context 'when user is an organizer' do
      let!(:conference1) { create(:conference) }
      let!(:conference2) { create(:conference) }
      let(:role) { create(:organizer_role, resource: conference1) }
      let(:user) { create(:user, role_ids: [role.id]) }
      let(:someuser) { create(:user) }
      let(:registration_public) { create(:registration, user: someuser, conference_id: conference1.id) }

      it{ should be_able_to(:manage, conference1) }
      it{ should_not be_able_to(:manage, conference2) }
      it{ should be_able_to(:manage, registration_public) }
      it{ should be_able_to(:create, Registration) }
    end

    context 'when user is part of cfp' do
      let!(:conference1) { create(:conference) }
      let!(:conference2) { create(:conference) }
      let(:role) { create(:role, name: 'cfp', resource: conference1) }
      let(:user) { create(:user, role_ids: role.id) }
      let(:event) { create(:event, conference_id: conference1.id) }
      let(:event_unconfirmed) { create(:event, conference_id: conference2.id) }
      let(:cfp) { create(:call_for_paper, conference: conference1) }

      it{ should_not be_able_to(:manage, conference1) }
      it{ should_not be_able_to(:manage, conference2) }
      it{ should be_able_to(:index, conference1) }
      it{ should be_able_to(:show, conference1) }

      it{ should be_able_to(:manage, event) }
      it{ should_not be_able_to(:manage, event_unconfirmed) }

      it{ should be_able_to(:manage, cfp) }
      it{ should be_able_to(:manage, create(:event_type, conference: conference1)) }
    end

    context 'when user has multiple roles' do
      let!(:conference1) { create(:conference) } # user is organizer
      let!(:conference2) { create(:conference) } # user is cfp
      let!(:conference3) { create(:conference) } # user is info_desk
      let!(:conference4) { create(:conference) } # user is volunteer coordinator
      let!(:conference5) { create(:conference, splashpage: create(:splashpage, public: true)) } # user has no role
      let!(:conference6) { create(:conference, splashpage: create(:splashpage, public: false)) } # user has no role
      let(:role_organizer) { create(:role, name: 'organizer', resource: conference1) }
      let(:role_cfp) { create(:role, name: 'cfp', resource: conference2) }
      let(:role_info_desk) { create(:role, name: 'info_desk', resource: conference3) }
      let(:role_volunteer_coordinator) { create(:role, name: 'volunteer_coordinator', resource: conference4) }
      let(:user) { create(:user, role_ids: [role_cfp.id, role_organizer.id, role_cfp.id, role_info_desk.id, role_volunteer_coordinator.id]) }
      let(:admin) { create(:admin) }

      it{ should be_able_to(:manage, conference1) }
      it{ should_not be_able_to(:update, conference2) }
      it{ should_not be_able_to(:update, conference3) }
      it{ should_not be_able_to(:update, conference4) }
      it{ should_not be_able_to(:update, conference5) }

      it{ should be_able_to(:show, conference1) }
      it{ should be_able_to(:show, conference2) }
      it{ should be_able_to(:show, conference3) }
      it{ should be_able_to(:show, conference4) }
      it{ should be_able_to(:show, conference5) }
      it{ should be_able_to(:show, conference6) }

      it{ should be_able_to(:manage, conference1.venue) }
      it{ should_not be_able_to(:manage, conference2.venue) }
      it{ should_not be_able_to(:manage, conference3.venue) }
      it{ should_not be_able_to(:manage, conference4.venue) }
      it{ should_not be_able_to(:manage, conference5.venue) }

      it{ should be_able_to(:manage, conference1.registrations.new) }
      it{ should_not be_able_to(:manage, conference2.registrations.new) }
      it{ should be_able_to(:manage, conference3.registrations.new) }
      it{ should_not be_able_to(:manage, conference4.registrations.new) }
      it{ should_not be_able_to(:manage, conference5.registrations.new) }

      it{ should be_able_to(:manage, conference1.events.new) }
      it{ should be_able_to(:manage, conference2.events.new) }
      it{ should_not be_able_to(:manage, conference3.events.new) }
      it{ should_not be_able_to(:manage, conference4.events.new) }
      it{ should_not be_able_to(:manage, conference5.events.new) }

      it{ should be_able_to(:manage, Question.new(conference_id: conference1.id)) }
      it{ should_not be_able_to(:manage, Question.new(conference_id: conference2.id)) }
      it{ should be_able_to(:manage, Question.new(conference_id: conference3.id)) }
      it{ should_not be_able_to(:manage, Question.new(conference_id: conference4.id)) }
      it{ should_not be_able_to(:manage, Question.new(conference_id: conference5.id)) }
    end
  end
end
