require 'spec_helper'
require 'cancan/matchers'

describe 'User' do
  describe 'Abilities' do
    subject(:ability){ Ability.new(user) }
    let(:user){ nil }
    let(:conference_not_public) { create(:conference, make_conference_public: false) }
    let(:conference_public) { create(:conference, make_conference_public: true) }
    let(:event_confirmed) { create(:event, state: 'confirmed') }
    let(:someevent) { create(:event) }

    context 'when is a guest' do  # Test abilities for guest users

      it{ should be_able_to(:show, conference_public)}
      it{ should_not be_able_to(:show, conference_not_public)}

      it{ should be_able_to(:show, event_confirmed)}
      it{ should_not be_able_to(:show, someevent)}

      it{ should be_able_to(:index, :schedule)}

      it{ should_not be_able_to(:create, Event)}
      it{ should_not be_able_to(:manage, Event)}
      it{ should_not be_able_to(:manage, Conference)}
      it{ should_not be_able_to(:manage, :any)}
    end

    context 'when is a Signed In User' do # Test abilities for signed in users (without any role)
      let(:user) { create(:participant) }
      let(:someuser) { create(:participant) }
      let(:registration1) { create(:registration, conference: conference_public, user: user) }
      let(:registration2) { create(:registration, conference: conference_not_public, user: someuser) }

      it{ should be_able_to(:create, Event) } # Can create a new proposal
      it{ should be_able_to(:index, Event) } # Can access proposal index page
      it{ should_not be_able_to(:manage, Event.new) } # Cannot manage events that are not theirs
      it{ should be_able_to(:show, event_confirmed) } # Can only view confirmed events
      it{ should_not be_able_to(:show, someevent) }

      # Can register for a conference
      it{ should be_able_to(:register, registration1) }
      it{ should be_able_to(:update, registration1) }
      it{ should be_able_to(:unregister, registration1) }
      # Cannot change the registration of other people
      it{ should_not be_able_to(:register, registration2) }
      it{ should_not be_able_to(:update, registration2) }
      it{ should_not be_able_to(:unregister, registration2) }

      # Can see the conference splash page only if conference is public
      it{ should be_able_to(:show, conference_public)}
      it{ should_not be_able_to(:show, conference_not_public)}

      # Cannot manage a conference
      it{ should_not be_able_to(:manage, conference_public) }
    end

    context '#is_admin?' do
      let(:user) { create(:admin) }

      it{ should be_able_to(:manage, User) }
    end

    context 'signed in users can manage their events' do
      let(:user) { create(:participant) }
      let(:user2) { create(:participant) }
      let(:myevent) { create(:event, users: [user]) }
      let(:someevent) { create(:event, users: [user2]) }

      # Users are able to update and destroy their own events
      it{ should be_able_to(:update, myevent) }
      it{ should be_able_to(:destroy, myevent) }
      it{ should be_able_to(:manage, myevent) }

      # Users are not able to update and destroy other users events
      it{ should_not be_able_to(:update, someevent) }
      it{ should_not be_able_to(:destroy, someevent) }
    end

    context 'when is an organizer' do
      let!(:conference1) { create(:conference) }
      let!(:conference2) { create(:conference) }
      let(:role) { create(:role, name: 'organizer', resource: conference1) }
      let(:user) { create(:user, role_ids: role.id) }
      let(:someuser) { create(:user) }
      let(:registration1) { create(:registration, user: someuser, conference_id: conference1.id) }

      it{ should be_able_to(:manage, conference1) }
      it{ should_not be_able_to(:manage, conference2) }
      it{ should be_able_to(:manage, registration1) }
      it{ should be_able_to(:create, Registration) }
    end

    context 'when is part of cfp' do
      let!(:conference1) { create(:conference) }
      let!(:conference2) { create(:conference) }
      let(:role) { create(:role, name: 'cfp', resource: conference1) }
      let(:user) { create(:user, role_ids: role.id) }
      let(:event) { create(:event, conference_id: conference1.id) }
      let(:someevent) { create(:event, conference_id: conference2.id) }
      let(:cfp) { create(:call_for_papers, conference: conference1) }

      it{ should_not be_able_to(:manage, conference1) }
      it{ should_not be_able_to(:manage, conference2) }
      it{ should be_able_to(:index, conference1) }
      it{ should be_able_to(:show, conference1) }

      it{ should be_able_to(:manage, event) }
      it{ should_not be_able_to(:manage, someevent) }

      it{ should be_able_to(:manage, cfp) }
      it{ should be_able_to(:manage, create(:event_type, conference: conference1)) }
#       it{ should_not be_able_to(:create, Registration) }
    end
  end
end
