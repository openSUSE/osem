require 'spec_helper'
require 'cancan/matchers'

describe 'User' do
  describe 'Abilities' do
    let!(:admin) { create(:admin) }

    # see https://github.com/CanCanCommunity/cancancan/wiki/Testing-Abilities
    subject(:ability){ Ability.new(user) }
    let(:user){ nil }

    let!(:my_conference) { create(:full_conference) }
    let!(:my_cfp) { create(:cfp, program: my_conference.program) }
    let(:my_venue) { my_conference.venue || create(:venue, conference: my_conference) }
    let(:my_registration) { create(:registration, conference: my_conference, user: admin) }

    let(:other_registration) { create(:registration, conference: conference_public) }
    let(:my_event) { create(:event_full, program: my_conference.program) }
    let(:my_room) { create(:room, venue: my_conference.venue) }
    let!(:my_event_scheduled) { create(:event_full, program: my_conference.program, room_id: my_room.id) }
    let(:other_event) { create(:event_full, program: conference_public.program) }

    let(:conference_not_public) { create(:conference, splashpage: create(:splashpage, public: false)) }
    let(:conference_public) { create(:full_conference, splashpage: create(:splashpage, public: true)) }
    let!(:conference_public_cfp) { create(:cfp, program: conference_public.program) }

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

      it do
          conference_public.program.schedule_public = true
          conference_public.program.save
          should be_able_to(:schedule, conference_public)
      end
      it{ should_not be_able_to(:schedule, conference_not_public)}

      it{ should be_able_to(:show, event_confirmed)}
      it{ should_not be_able_to(:show, event_unconfirmed)}

      it{ should be_able_to(:show, commercial_event_confirmed)}
      it{ should_not be_able_to(:show, commercial_event_unconfirmed)}

      it{ should be_able_to(:show, User)}

      it{ should be_able_to(:create, Registration)}
      it{ should be_able_to(:show, Registration.new)}
      it{ should_not be_able_to(:manage, registration)}

      it{ should be_able_to(:create, Event)}
      it{ should be_able_to(:show, Event.new)}

      it{ should_not be_able_to(:manage, :any)}
    end

    # Test abilities for signed in users (without any role)
    context 'when user is signed in' do
      let(:user) { create(:user) }
      let(:user2) { create(:user) }
      let(:subscription) { create(:subscription, user: user) }
      let(:registration_public) { create(:registration, conference: conference_public, user: user) }
      let(:registration_not_public) { create(:registration, conference: conference_not_public, user: user) }

      let(:user_event) { create(:event, users: [user]) }
      let(:user_commercial) { create(:commercial, commercialable: user_event) }

      it{ should be_able_to(:manage, user) }

      it{ should be_able_to(:manage, registration_public) }
      it{ should be_able_to(:manage, registration_not_public) }

      it{ should be_able_to(:index, Ticket) }
      it{ should be_able_to(:manage, TicketPurchase.new(user_id: user.id)) }

      it{ should be_able_to(:create, Subscription.new(user_id: user.id)) }
      it{ should be_able_to(:destroy, subscription) }

      it{ should be_able_to(:create, Event) }
      it{ should be_able_to(:manage, user_event) }
      it{ should_not be_able_to(:manage, event_unconfirmed) }

      it{ should be_able_to(:create, user_event.commercials.new) }
      it{ should be_able_to(:manage, user_commercial) }
      it{ should_not be_able_to(:manage, commercial_event_unconfirmed) }
    end

    context 'user #is_admin?' do
      let(:venue) { my_conference.venue }
      let(:room) { create(:room, venue: venue) }
      let!(:event) { create(:event_full, program: my_conference.program, room_id: room.id) }
      let(:user) { create(:admin) }
      it{ should be_able_to(:manage, :all) }
      it{ should_not be_able_to(:destroy, my_conference.program) }
      it{ should_not be_able_to(:destroy, my_venue) }
    end

    context 'when user has the role organizer' do
      let!(:my_conference) { create(:full_conference) }
      let(:role) { Role.find_by(name: 'organizer', resource: my_conference) }
      let(:user) { create(:user, role_ids: [role.id]) }

      it{ should_not be_able_to(:destroy, my_conference.program) }
      it 'when there is a room assigned to an event' do
        should_not be_able_to(:destroy, my_venue)
      end

      it 'when there are no rooms used' do
        my_event_scheduled.room_id = nil
        my_event_scheduled.save!
        my_event_scheduled.reload
        should be_able_to(:destroy, my_venue)
      end

      it{ should be_able_to([:create, :new], Conference) }
      it{ should be_able_to(:manage, my_conference) }
      it{ should_not be_able_to(:manage, conference_public) }
      it{ should be_able_to(:manage, my_conference.splashpage) }
      it{ should_not be_able_to(:manage, conference_public.splashpage) }
      it{ should be_able_to(:manage, my_conference.contact) }
      it{ should_not be_able_to(:manage, conference_public.contact) }
      it{ should be_able_to(:manage, my_conference.email_settings) }
      it{ should_not be_able_to(:manage, conference_public.email_settings) }
      it{ should be_able_to(:manage, my_conference.campaigns.first) }
      it{ should_not be_able_to(:manage, conference_public.campaigns.first) }
      it{ should be_able_to(:manage, my_conference.targets.first) }
      it{ should_not be_able_to(:manage, conference_public.targets.first) }
      it{ should be_able_to(:manage, my_conference.commercials.first) }
      it{ should_not be_able_to(:manage, conference_public.commercials.first) }
      it{ should be_able_to(:manage, my_conference.registration_period) }
      it{ should_not be_able_to(:manage, conference_public.registration_period) }
      it{ should be_able_to(:manage, my_conference.questions.first) }
      it{ should_not be_able_to(:manage, conference_public.questions.first) }
      it{ should be_able_to(:manage, my_conference.program.cfp) }
      it{ should_not be_able_to(:manage, conference_public.program.cfp) }
      it{ should be_able_to(:manage, my_conference.venue) }
      it{ should_not be_able_to(:manage, conference_public.venue) }
      it{ should be_able_to(:manage, my_conference.lodgings.first) }
      it{ should_not be_able_to(:manage, conference_public.lodgings.first) }
      it{ should be_able_to(:manage, my_conference.sponsors.first) }
      it{ should_not be_able_to(:manage, conference_public.sponsors.first) }
      it{ should be_able_to(:manage, my_conference.sponsorship_levels.first) }
      it{ should_not be_able_to(:manage, conference_public.sponsorship_levels.first) }
      it{ should be_able_to(:manage, my_conference.tickets.first) }
      it{ should_not be_able_to(:manage, conference_public.tickets.first) }

      it{ should be_able_to(:manage, my_registration) }
      it{ should_not be_able_to(:manage, other_registration) }

      it{ should be_able_to(:manage, my_event) }
      it{ should_not be_able_to(:manage, other_event) }
      it{ should be_able_to(:manage, my_event.event_type) }
      it{ should_not be_able_to(:manage, other_event.event_type) }
      it{ should be_able_to(:manage, my_event.track) }
      it{ should_not be_able_to(:manage, other_event.track) }
      it{ should be_able_to(:manage, my_event.difficulty_level) }
      it{ should_not be_able_to(:manage, other_event.difficulty_level) }
      it{ should be_able_to(:manage, my_event.commercials.first) }
      it{ should_not be_able_to(:manage, other_event.commercials.first) }
      it{ should be_able_to(:index, my_event.comment_threads.first) }
      it{ should_not be_able_to(:index, other_event.comment_threads.first) }
    end

    context 'when user has the role cfp' do
      let!(:my_conference) { create(:full_conference) }
      let(:role) { Role.find_by(name: 'cfp', resource: my_conference) }
      let(:user) { create(:user, role_ids: [role.id]) }

      it{ should_not be_able_to([:create, :new], Conference.new) }
      it{ should_not be_able_to(:manage, my_conference) }
      it{ should_not be_able_to(:manage, conference_public) }
      it{ should_not be_able_to(:manage, my_conference.splashpage) }
      it{ should_not be_able_to(:manage, conference_public.splashpage) }
      it{ should_not be_able_to(:manage, my_conference.contact) }
      it{ should_not be_able_to(:manage, conference_public.contact) }
      it{ should be_able_to(:manage, my_conference.email_settings) }
      it{ should_not be_able_to(:manage, conference_public.email_settings) }
      it{ should_not be_able_to(:manage, my_conference.campaigns.first) }
      it{ should_not be_able_to(:manage, conference_public.campaigns.first) }
      it{ should_not be_able_to(:manage, my_conference.targets.first) }
      it{ should_not be_able_to(:manage, conference_public.targets.first) }
      it{ should_not be_able_to(:manage, my_conference.commercials.first) }
      it{ should_not be_able_to(:manage, conference_public.commercials.first) }
      it{ should_not be_able_to(:manage, my_conference.registration_period) }
      it{ should_not be_able_to(:manage, conference_public.registration_period) }
      it{ should_not be_able_to(:manage, my_conference.questions.first) }
      it{ should_not be_able_to(:manage, conference_public.questions.first) }
      it{ should be_able_to(:manage, my_conference.program.cfp) }
      it{ should_not be_able_to(:manage, conference_public.program.cfp) }
      it{ should_not be_able_to(:manage, my_conference.venue) }
      it{ should be_able_to(:show, my_conference.venue) }
      it{ should_not be_able_to(:manage, conference_public.venue) }
      it{ should_not be_able_to(:manage, my_conference.lodgings.first) }
      it{ should_not be_able_to(:manage, conference_public.lodgings.first) }
      it{ should_not be_able_to(:manage, my_conference.sponsors.first) }
      it{ should_not be_able_to(:manage, conference_public.sponsors.first) }
      it{ should_not be_able_to(:manage, my_conference.sponsorship_levels.first) }
      it{ should_not be_able_to(:manage, conference_public.sponsorship_levels.first) }
      it{ should_not be_able_to(:manage, my_conference.tickets.first) }
      it{ should_not be_able_to(:manage, conference_public.tickets.first) }

      it{ should_not be_able_to(:manage, my_registration) }
      it{ should_not be_able_to(:manage, other_registration) }

      it{ should be_able_to(:manage, my_event) }
      it{ should_not be_able_to(:manage, other_event) }
      it{ should be_able_to(:manage, my_event.event_type) }
      it{ should_not be_able_to(:manage, other_event.event_type) }
      it{ should be_able_to(:manage, my_event.track) }
      it{ should_not be_able_to(:manage, other_event.track) }
      it{ should be_able_to(:manage, my_event.difficulty_level) }
      it{ should_not be_able_to(:manage, other_event.difficulty_level) }
      it{ should be_able_to(:manage, my_event.commercials.first) }
      it{ should_not be_able_to(:manage, other_event.commercials.first) }
      it{ should be_able_to(:index, my_event.comment_threads.first) }
      it{ should_not be_able_to(:index, other_event.comment_threads.first) }
    end

    context 'when user has the role info_desk' do
      let!(:my_conference) { create(:full_conference) }
      let(:role) { Role.find_by(name: 'info_desk', resource: my_conference) }
      let(:user) { create(:user, role_ids: [role.id]) }

      it{ should_not be_able_to([:create, :new], Conference.new) }
      it{ should_not be_able_to(:manage, my_conference) }
      it{ should_not be_able_to(:manage, conference_public) }
      it{ should_not be_able_to(:manage, my_conference.splashpage) }
      it{ should_not be_able_to(:manage, conference_public.splashpage) }
      it{ should_not be_able_to(:manage, my_conference.contact) }
      it{ should_not be_able_to(:manage, conference_public.contact) }
      it{ should_not be_able_to(:manage, my_conference.email_settings) }
      it{ should_not be_able_to(:manage, conference_public.email_settings) }
      it{ should_not be_able_to(:manage, my_conference.campaigns.first) }
      it{ should_not be_able_to(:manage, conference_public.campaigns.first) }
      it{ should_not be_able_to(:manage, my_conference.targets.first) }
      it{ should_not be_able_to(:manage, conference_public.targets.first) }
      it{ should_not be_able_to(:manage, my_conference.commercials.first) }
      it{ should_not be_able_to(:manage, conference_public.commercials.first) }
      it{ should_not be_able_to(:manage, my_conference.registration_period) }
      it{ should_not be_able_to(:manage, conference_public.registration_period) }
      it{ should be_able_to(:manage, my_conference.questions.first) }
      it{ should_not be_able_to(:manage, conference_public.questions.first) }
      it{ should_not be_able_to(:manage, my_conference.program.cfp) }
      it{ should_not be_able_to(:manage, conference_public.program.cfp) }
      it{ should_not be_able_to(:manage, my_conference.venue) }
      it{ should_not be_able_to(:show, my_conference.venue) }
      it{ should_not be_able_to(:manage, conference_public.venue) }
      it{ should_not be_able_to(:manage, my_conference.lodgings.first) }
      it{ should_not be_able_to(:manage, conference_public.lodgings.first) }
      it{ should_not be_able_to(:manage, my_conference.sponsors.first) }
      it{ should_not be_able_to(:manage, conference_public.sponsors.first) }
      it{ should_not be_able_to(:manage, my_conference.sponsorship_levels.first) }
      it{ should_not be_able_to(:manage, conference_public.sponsorship_levels.first) }
      it{ should_not be_able_to(:manage, my_conference.tickets.first) }
      it{ should_not be_able_to(:manage, conference_public.tickets.first) }

      it{ should be_able_to(:manage, my_registration) }
      it{ should_not be_able_to(:manage, other_registration) }

      it{ should_not be_able_to(:manage, my_event) }
      it{ should_not be_able_to(:manage, other_event) }
      it{ should_not be_able_to(:manage, my_event.event_type) }
      it{ should_not be_able_to(:manage, other_event.event_type) }
      it{ should_not be_able_to(:manage, my_event.track) }
      it{ should_not be_able_to(:manage, other_event.track) }
      it{ should_not be_able_to(:manage, my_event.difficulty_level) }
      it{ should_not be_able_to(:manage, other_event.difficulty_level) }
      it{ should_not be_able_to(:manage, my_event.commercials.first) }
      it{ should_not be_able_to(:manage, other_event.commercials.first) }
      it{ should_not be_able_to(:index, my_event.comment_threads.first) }
      it{ should_not be_able_to(:index, other_event.comment_threads.first) }
    end

    context 'when user has the role volunteers_coordinator' do
      let!(:my_conference) { create(:full_conference) }
      let(:role) { Role.find_by(name: 'volunteers_coordinator', resource: my_conference) }
      let(:user) { create(:user, role_ids: [role.id]) }

      it{ should_not be_able_to([:create, :new], Conference.new) }
      it{ should_not be_able_to(:manage, my_conference) }
      it{ should_not be_able_to(:manage, conference_public) }
      it{ should_not be_able_to(:manage, my_conference.splashpage) }
      it{ should_not be_able_to(:manage, conference_public.splashpage) }
      it{ should_not be_able_to(:manage, my_conference.contact) }
      it{ should_not be_able_to(:manage, conference_public.contact) }
      it{ should_not be_able_to(:manage, my_conference.email_settings) }
      it{ should_not be_able_to(:manage, conference_public.email_settings) }
      it{ should_not be_able_to(:manage, my_conference.campaigns.first) }
      it{ should_not be_able_to(:manage, conference_public.campaigns.first) }
      it{ should_not be_able_to(:manage, my_conference.targets.first) }
      it{ should_not be_able_to(:manage, conference_public.targets.first) }
      it{ should_not be_able_to(:manage, my_conference.commercials.first) }
      it{ should_not be_able_to(:manage, conference_public.commercials.first) }
      it{ should_not be_able_to(:manage, my_conference.registration_period) }
      it{ should_not be_able_to(:manage, conference_public.registration_period) }
      it{ should_not be_able_to(:manage, my_conference.questions.first) }
      it{ should_not be_able_to(:manage, conference_public.questions.first) }
      it{ should_not be_able_to(:manage, my_conference.program.cfp) }
      it{ should_not be_able_to(:manage, conference_public.program.cfp) }
      it{ should_not be_able_to(:manage, my_conference.venue) }
      it{ should_not be_able_to(:show, my_conference.venue) }
      it{ should_not be_able_to(:manage, conference_public.venue) }
      it{ should_not be_able_to(:manage, my_conference.lodgings.first) }
      it{ should_not be_able_to(:manage, conference_public.lodgings.first) }
      it{ should_not be_able_to(:manage, my_conference.sponsors.first) }
      it{ should_not be_able_to(:manage, conference_public.sponsors.first) }
      it{ should_not be_able_to(:manage, my_conference.sponsorship_levels.first) }
      it{ should_not be_able_to(:manage, conference_public.sponsorship_levels.first) }
      it{ should_not be_able_to(:manage, my_conference.tickets.first) }
      it{ should_not be_able_to(:manage, conference_public.tickets.first) }

      it{ should_not be_able_to(:manage, registration) }
      it{ should_not be_able_to(:manage, other_registration) }

      it{ should_not be_able_to(:manage, my_event) }
      it{ should_not be_able_to(:manage, other_event) }
      it{ should_not be_able_to(:manage, my_event.event_type) }
      it{ should_not be_able_to(:manage, other_event.event_type) }
      it{ should_not be_able_to(:manage, my_event.track) }
      it{ should_not be_able_to(:manage, other_event.track) }
      it{ should_not be_able_to(:manage, my_event.difficulty_level) }
      it{ should_not be_able_to(:manage, other_event.difficulty_level) }
      it{ should_not be_able_to(:manage, my_event.commercials.first) }
      it{ should_not be_able_to(:manage, other_event.commercials.first) }
      it{ should_not be_able_to(:index, my_event.comment_threads.first) }
      it{ should_not be_able_to(:index, other_event.comment_threads.first) }
      it 'should be_able to :manage Vposition'
      it 'should be_able to :manage Vday'
    end
  end
end
