# frozen_string_literal: true

require 'spec_helper'
require 'cancan/matchers'

describe 'User with admin role' do
  describe 'Abilities' do
    let!(:admin) { create(:admin) }

    # see https://github.com/CanCanCommunity/cancancan/wiki/Testing-Abilities
    subject(:ability){ AdminAbility.new(user) }
    let(:user){ nil }

    let!(:organization) { create(:organization) }
    let!(:my_conference) { create(:full_conference, organization: organization) }
    let!(:registration_ticket) { create(:registration_ticket, conference: my_conference) }
    let(:my_venue) { my_conference.venue || create(:venue, conference: my_conference) }
    let(:my_registration) { create(:registration, conference: my_conference, user: admin) }

    let(:other_registration) { create(:registration, conference: conference_public) }
    let(:my_event) { create(:event_full, program: my_conference.program) }
    let(:my_room) { create(:room, venue: my_conference.venue) }
    let!(:my_event_scheduled) { create(:event_full, program: my_conference.program, room_id: my_room.id) }
    let(:other_event) { create(:event_full, program: conference_public.program) }

    let(:conference_not_public) { create(:conference, splashpage: create(:splashpage, public: false)) }
    let(:conference_public) { create(:full_conference, splashpage: create(:splashpage, public: true)) }

    let(:event_confirmed) { create(:event, state: 'confirmed') }
    let(:event_unconfirmed) { create(:event) }

    let(:commercial_event_confirmed) { create(:commercial, commercialable: event_confirmed) }
    let(:commercial_event_unconfirmed) { create(:commercial, commercialable: event_unconfirmed) }
    let(:resource) { create(:resource, conference: my_conference) }
    let(:registration) { create(:registration) }

    let(:program_with_cfp) { create(:program, :with_cfp) }
    let(:program_without_cfp) { create(:program) }
    let(:conference_with_open_registration) { create(:conference) }
    let!(:open_registration_period) { create(:registration_period, conference: conference_with_open_registration, start_date: Date.current - 6.days) }
    let(:conference_with_closed_registration) { create(:conference) }
    let!(:closed_registration_period) { create(:registration_period, conference: conference_with_closed_registration, start_date: Date.current - 6.days, end_date: Date.current - 6.days) }

    let!(:my_schedule) { create(:schedule, program: my_conference.program) }
    let!(:other_schedule) { create(:schedule, program: conference_public.program) }

    let!(:my_event_schedule) { create(:event_schedule, schedule: my_schedule) }
    let!(:other_event_schedule) { create(:event_schedule, schedule: other_schedule) }

    let!(:my_self_organized_track) { create(:track, :self_organized, program: my_conference.program, state: 'confirmed') }

    context 'user #is_admin?' do
      let(:venue) { my_conference.venue }
      let(:room) { create(:room, venue: venue) }
      let!(:event) { create(:event_full, program: my_conference.program, room_id: room.id) }
      let(:user) { create(:admin) }
      it{ should be_able_to(:manage, :all) }
      it{ should_not be_able_to(:destroy, my_conference.program) }
      it{ should_not be_able_to(:destroy, my_venue) }
    end

    shared_examples 'user with any role' do
      let!(:other_organization) { create(:organization) }
      let!(:other_conference) { create(:conference, organization: other_organization) }

      it{ should_not be_able_to(:update, Role.find_by(name: 'organization_admin', resource: other_organization)) }
      it{ should_not be_able_to(:edit, Role.find_by(name: 'organization_admin', resource: other_organization)) }
      it{ should be_able_to(:admins, organization) }

      it{ should_not be_able_to(:new, User.new) }
      it{ should_not be_able_to(:create, User.new) }
      it{ should_not be_able_to(:manage, User) }

      %w[organizer cfp info_desk volunteers_coordinator].each do |role|
        it{ should_not be_able_to(:toggle_user, Role.find_by(name: role, resource: other_conference)) }
        it{ should_not be_able_to(:update, Role.find_by(name: role, resource: other_conference)) }
        it{ should_not be_able_to(:edit, Role.find_by(name: role, resource: other_conference)) }
        it{ should be_able_to(:show, Role.find_by(name: role, resource: other_conference)) }
        it{ should be_able_to(:index, Role.find_by(name: role, resource: other_conference)) }
      end

      context 'accesses track organizers' do
        before :each do
          other_self_organized_track = create(:track, :self_organized)
          @other_track_organizer_role = Role.where(name: 'track_organizer', resource: other_self_organized_track).first_or_create
        end

        it{ should_not be_able_to(:toggle_user, @other_track_organizer_role) }
        it{ should_not be_able_to(:update, @other_track_organizer_role) }
        it{ should_not be_able_to(:edit, @other_track_organizer_role) }
        it{ should be_able_to(:show, @other_track_organizer_role) }
        it{ should be_able_to(:index, @other_track_organizer_role) }
      end
    end

    shared_examples 'user with non-organizer role' do |role_name|
      %w[organizer cfp info_desk volunteers_coordinator].each do |role|
        if role == role_name
          it{ should be_able_to(:toggle_user, Role.find_by(name: role, resource: my_conference)) }
        else
          it{ should_not be_able_to(:toggle_user, Role.find_by(name: role, resource: my_conference)) }
        end
        it{ should_not be_able_to(:update, Role.find_by(name: role, resource: my_conference)) }
        it{ should_not be_able_to(:edit, Role.find_by(name: role, resource: my_conference)) }
        it{ should be_able_to(:show, Role.find_by(name: role, resource: my_conference)) }
        it{ should be_able_to(:index, Role.find_by(name: role, resource: my_conference)) }
      end

      context 'accesses track organizers' do
        before :each do
          @track_organizer_role = Role.where(name: 'track_organizer', resource: my_self_organized_track).first_or_create
        end

        if role_name == 'track_organizer'
          it{ should be_able_to(:toggle_user, @track_organizer_role) }
        else
          it{ should_not be_able_to(:toggle_user, @track_organizer_role) }
        end
        it{ should_not be_able_to(:update, @track_organizer_role) }
        it{ should_not be_able_to(:edit, @track_organizer_role) }
        it{ should be_able_to(:show, @track_organizer_role) }
        it{ should be_able_to(:index, @track_organizer_role) }
      end
    end

    context 'when user has the role organization_admin' do
      let(:role) { Role.find_by(name: 'organization_admin', resource: organization) }
      let(:user) { create(:user, role_ids: [role.id]) }
      let(:other_organization) { create(:organization) }
      let(:other_conference) { create(:conference, organization: other_organization) }

      it{ should be_able_to(:assign_org_admins, organization) }
      it{ should be_able_to(:unassign_org_admins, organization) }
      it{ should be_able_to(:manage, my_conference) }
      it{ should be_able_to(:read, organization) }
      it{ should be_able_to(:update, organization) }
      it{ should be_able_to(:destroy, organization) }
      it{ should be_able_to(:new, Conference.new) }
      it{ should be_able_to(:create, Conference.new(organization_id: organization.id)) }
      it{ should_not be_able_to(:manage, other_conference) }
      it{ should_not be_able_to(:create, Conference.new(organization_id: other_organization.id)) }
      it{ should_not be_able_to(:new, Organization.new) }
      it{ should_not be_able_to(:create, Organization.new) }

      it_behaves_like 'user with any role'
    end

    context 'when user has the role organizer' do
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

      it{ should_not be_able_to(:new, Organization.new) }
      it{ should_not be_able_to(:create, Organization.new) }
      it{ should_not be_able_to(:new, Conference.new) }
      it{ should_not be_able_to(:create, Conference.new) }
      it{ should be_able_to(:read, my_conference) }
      it{ should be_able_to(:update, my_conference) }
      it{ should be_able_to(:destroy, my_conference) }
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
      it{ should be_able_to(:manage, my_schedule) }
      it{ should_not be_able_to(:manage, other_schedule) }
      it{ should be_able_to(:manage, my_event_schedule) }
      it{ should_not be_able_to(:manage, other_event_schedule) }
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

      it{ should be_able_to(:manage, resource) }

      it{ should_not be_able_to(:assign_org_admins, organization) }
      it{ should_not be_able_to(:unassign_org_admins, organization) }

      %w[organizer cfp info_desk volunteers_coordinator].each do |role|
        it{ should be_able_to(:toggle_user, Role.find_by(name: role, resource: my_conference)) }
        it{ should be_able_to(:edit, Role.find_by(name: role, resource: my_conference)) }
        it{ should be_able_to(:update, Role.find_by(name: role, resource: my_conference)) }
        it{ should be_able_to(:show, Role.find_by(name: role, resource: my_conference)) }
        it{ should be_able_to(:index, Role.find_by(name: role, resource: my_conference)) }
      end

      context 'can manage track organizers' do
        before :each do
          @track_organizer_role = Role.where(name: 'track_organizer', resource: my_self_organized_track).first_or_create
        end

        it{ should be_able_to(:toggle_user, @track_organizer_role) }
        it{ should be_able_to(:edit, @track_organizer_role) }
        it{ should be_able_to(:update, @track_organizer_role) }
        it{ should be_able_to(:show, @track_organizer_role) }
        it{ should be_able_to(:index, @track_organizer_role) }
      end

      it_behaves_like 'user with any role'
    end

    context 'when user has the role cfp' do
      let(:role) { Role.find_by(name: 'cfp', resource: my_conference) }
      let(:user) { create(:user, role_ids: [role.id]) }

      it{ should_not be_able_to(:new, Conference.new) }
      it{ should_not be_able_to(:create, Conference.new) }
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
      it{ should be_able_to(:manage, my_schedule) }
      it{ should_not be_able_to(:manage, other_schedule) }
      it{ should_not be_able_to(:manage, my_event_schedule) }
      it{ should_not be_able_to(:manage, other_event_schedule) }
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

      it{ should_not be_able_to(:manage, resource) }
      it{ should be_able_to(:index, resource) }
      it{ should be_able_to(:show, resource) }
      it{ should be_able_to(:update, resource) }
      it{ should_not be_able_to(:assign_org_admins, organization) }
      it{ should_not be_able_to(:unassign_org_admins, organization) }

      it_behaves_like 'user with any role'
      it_behaves_like 'user with non-organizer role', 'cfp'
    end

    context 'when user has the role info_desk' do
      let(:role) { Role.find_by(name: 'info_desk', resource: my_conference) }
      let(:user) { create(:user, role_ids: [role.id]) }

      it{ should_not be_able_to(:new, Conference.new) }
      it{ should_not be_able_to(:create, Conference.new) }
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
      it{ should_not be_able_to(:manage, my_schedule) }
      it{ should_not be_able_to(:manage, other_schedule) }
      it{ should_not be_able_to(:manage, my_event_schedule) }
      it{ should_not be_able_to(:manage, other_event_schedule) }
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

      it{ should_not be_able_to(:manage, resource) }
      it{ should be_able_to(:index, resource) }
      it{ should be_able_to(:show, resource) }
      it{ should be_able_to(:update, resource) }
      it{ should_not be_able_to(:assign_org_admins, organization) }
      it{ should_not be_able_to(:unassign_org_admins, organization) }

      it_behaves_like 'user with any role'
      it_behaves_like 'user with non-organizer role', 'info_desk'
    end

    context 'when user has the role volunteers_coordinator' do
      let(:role) { Role.find_by(name: 'volunteers_coordinator', resource: my_conference) }
      let(:user) { create(:user, role_ids: [role.id]) }

      it{ should_not be_able_to(:new, Conference.new) }
      it{ should_not be_able_to(:create, Conference.new) }
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
      it{ should_not be_able_to(:manage, my_schedule) }
      it{ should_not be_able_to(:manage, other_schedule) }
      it{ should_not be_able_to(:manage, my_event_schedule) }
      it{ should_not be_able_to(:manage, other_event_schedule) }
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

      it{ should_not be_able_to(:manage, resource) }
      it{ should be_able_to(:index, resource) }
      it{ should be_able_to(:show, resource) }
      it{ should be_able_to(:update, resource) }
      it{ should_not be_able_to(:assign_org_admins, organization) }
      it{ should_not be_able_to(:unassign_org_admins, organization) }

      it 'should be_able to :manage Vposition'
      it 'should be_able to :manage Vday'

      it_behaves_like 'user with any role'
      it_behaves_like 'user with non-organizer role', 'volunteers_coordinator'
    end

    context 'when user has the role track_organizer' do

      let(:role) { Role.where(name: 'track_organizer', resource: my_self_organized_track).first_or_create }
      let(:user) { create(:user, role_ids: [role.id]) }
      let(:new_track) { build(:track, program: my_conference.program) }
      let(:new_event) { build(:event, program: my_conference.program) }
      let(:new_schedule) { build(:schedule, program: my_conference.program) }
      let(:new_track_schedule) { build(:schedule, program: my_conference.program, track: new_track) }
      let(:my_self_organized_track_event) { create(:event, program: my_conference.program, track: my_self_organized_track) }
      let(:my_self_organized_track_event_commercial) { create(:commercial, commercialable: my_self_organized_track_event) }
      let(:my_self_organized_track_schedule) { create(:schedule, program: my_conference.program, track: my_self_organized_track) }
      let(:my_self_organized_track_event_schedule) { create(:event_schedule, event: my_self_organized_track_event, schedule: my_self_organized_track_schedule, room: my_self_organized_track.room) }

      it{ should_not be_able_to(:new, Conference.new) }
      it{ should_not be_able_to(:create, Conference.new) }
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
      it{ should_not be_able_to(:manage, my_schedule) }
      it{ should_not be_able_to(:manage, other_schedule) }
      it{ should_not be_able_to(:manage, my_event_schedule) }
      it{ should_not be_able_to(:manage, other_event_schedule) }
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

      it{ should_not be_able_to(:manage, resource) }

      it{ should be_able_to(:show, my_conference.program) }
      it{ should be_able_to(:update, new_track) }
      it{ should be_able_to(:manage, my_self_organized_track) }
      it{ should_not be_able_to(:edit, my_self_organized_track) }
      it{ should_not be_able_to(:update, my_self_organized_track) }

      it{ should_not be_able_to(:assign_org_admins, organization) }
      it{ should_not be_able_to(:unassign_org_admins, organization) }

      it{ should be_able_to(:update, new_event) }
      it{ should be_able_to(:manage, my_self_organized_track_event) }
      it{ should be_able_to(:manage, my_self_organized_track_event_commercial) }

      it{ should be_able_to(:update, new_schedule) }
      it{ should be_able_to(:new, new_track_schedule) }
      it{ should be_able_to(:manage, my_self_organized_track_schedule) }
      it{ should be_able_to(:manage, my_self_organized_track_event_schedule) }

      it_behaves_like 'user with any role'
      it_behaves_like 'user with non-organizer role', 'track_organizer'
    end
  end
end
