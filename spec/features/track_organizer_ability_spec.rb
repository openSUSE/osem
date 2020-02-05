# frozen_string_literal: true

require 'spec_helper'

feature 'Has correct abilities' do

  let(:organization) { create(:organization) }
  let(:conference) { create(:full_conference, organization: organization) }
  let(:self_organized_track) { create(:track, :self_organized, program: conference.program, state: 'confirmed') }
  let(:role_track_organizer) { Role.where(name: 'track_organizer', resource: self_organized_track).first_or_create }
  let(:user_track_organizer) { create(:user, role_ids: [role_track_organizer.id]) }

  context 'when user is track organizer' do
    before do
      sign_in user_track_organizer
    end

    scenario 'for organization and conference attributes' do
      visit admin_conference_path(conference.short_title)
      expect(current_path).to eq(admin_conference_path(conference.short_title))

      expect(page).to have_selector('li.nav-header.nav-header-bigger a', text: 'Dashboard')
      expect(page).to_not have_link('Basics', href: "/admin/conferences/#{conference.short_title}/edit")
      expect(page).to have_text('Basics')
      expect(page).to_not have_link('Contact', href: "/admin/conferences/#{conference.short_title}/contact/edit")
      expect(page).to have_link('Materials', href: "/admin/conferences/#{conference.short_title}/commercials")
      expect(page).to_not have_link('Splashpage', href: "/admin/conferences/#{conference.short_title}/splashpage")
      expect(page).to_not have_link('Venue', href: "/admin/conferences/#{conference.short_title}/venue")
      expect(page).to_not have_link('Rooms', href: "/admin/conferences/#{conference.short_title}/venue/rooms")
      expect(page).to_not have_link('Lodgings', href: "/admin/conferences/#{conference.short_title}/lodgings")
      expect(page).to have_link('Program', href: "/admin/conferences/#{conference.short_title}/program")
      expect(page).to_not have_link('Call for Papers', href: "/admin/conferences/#{conference.short_title}/program/cfps")
      expect(page).to have_link('Events', href: "/admin/conferences/#{conference.short_title}/program/events")
      expect(page).to have_link('Tracks', href: "/admin/conferences/#{conference.short_title}/program/tracks")
      expect(page).to_not have_link('Event Types', href: "/admin/conferences/#{conference.short_title}/program/event_types")
      expect(page).to_not have_link('Difficulty Levels', href: "/admin/conferences/#{conference.short_title}/program/difficulty_levels")
      expect(page).to have_link('Schedules', href: "/admin/conferences/#{conference.short_title}/schedules")
      expect(page).to have_link('Reports', href: "/admin/conferences/#{conference.short_title}/program/reports")
      expect(page).to_not have_link('Registrations', href: "/admin/conferences/#{conference.short_title}/registrations")
      expect(page).to_not have_link('Registration Period', href: "/admin/conferences/#{conference.short_title}/registration_period")
      expect(page).to_not have_link('Questions', href: "/admin/conferences/#{conference.short_title}/questions")
      expect(page).to_not have_text('Donations')
      expect(page).to_not have_link('Sponsorship Levels', href: "/admin/conferences/#{conference.short_title}/sponsorship_levels")
      expect(page).to_not have_link('Sponsors', href: "/admin/conferences/#{conference.short_title}/sponsors")
      expect(page).to_not have_link('Tickets', href: "/admin/conferences/#{conference.short_title}/tickets")
      expect(page).to_not have_link('E-Mails', href: "/admin/conferences/#{conference.short_title}/emails")
      expect(page).to have_link('Roles', href: "/admin/conferences/#{conference.short_title}/roles")
      expect(page).to_not have_link('Resources', href: "/admin/conferences/#{conference.short_title}/resources")
      expect(page).to_not have_link('New Conference', href: '/admin/conferences/new')

      visit edit_admin_conference_path(conference.short_title)
      expect(current_path).to eq root_path

      visit edit_admin_conference_contact_path(conference.short_title)
      expect(current_path).to eq root_path

      visit admin_conference_commercials_path(conference.short_title)
      expect(current_path).to eq admin_conference_commercials_path(conference.short_title)

      visit new_admin_conference_splashpage_path(conference.short_title)
      expect(current_path).to eq root_path

      visit edit_admin_conference_splashpage_path(conference.short_title)
      expect(current_path).to eq root_path

      visit new_admin_conference_venue_path(conference.short_title)
      expect(current_path).to eq root_path

      conference.venue = create(:venue)
      visit edit_admin_conference_venue_path(conference.short_title)
      expect(current_path).to eq root_path

      visit admin_conference_venue_rooms_path(conference.short_title)
      expect(current_path).to eq root_path

      create(:room, venue: conference.venue)
      visit edit_admin_conference_venue_room_path(conference.short_title, conference.venue.rooms.first)
      expect(current_path).to eq root_path

      visit admin_conference_lodgings_path(conference.short_title)
      expect(current_path).to eq root_path

      visit new_admin_conference_lodging_path(conference.short_title)
      expect(current_path).to eq root_path

      create(:lodging, conference: conference)
      visit edit_admin_conference_lodging_path(conference.short_title, conference.lodgings.first)
      expect(current_path).to eq root_path

      visit new_admin_conference_program_path(conference.short_title)
      expect(current_path).to eq root_path

      visit edit_admin_conference_program_path(conference.short_title)
      expect(current_path).to eq root_path

      visit new_admin_conference_program_cfp_path(conference.short_title)
      expect(current_path).to eq root_path

      visit edit_admin_conference_program_cfp_path(conference.short_title, conference.program.cfp)
      expect(current_path).to eq root_path

      visit admin_conference_program_events_path(conference.short_title)
      expect(current_path).to eq admin_conference_program_events_path(conference.short_title)

      create(:event, program: conference.program)
      visit edit_admin_conference_program_event_path(conference.short_title, conference.program.events.first)
      expect(current_path).to eq root_path

      self_organized_track_event = create(:event, program: conference.program, track: self_organized_track)
      visit edit_admin_conference_program_event_path(conference.short_title, self_organized_track_event)
      expect(current_path).to eq(edit_admin_conference_program_event_path(conference.short_title, self_organized_track_event))

      visit admin_conference_program_event_types_path(conference.short_title)
      expect(current_path).to eq root_path

      visit new_admin_conference_program_event_type_path(conference.short_title)
      expect(current_path).to eq root_path

      visit edit_admin_conference_program_event_type_path(conference.short_title, conference.program.event_types.first)
      expect(current_path).to eq root_path

      visit admin_conference_program_difficulty_levels_path(conference.short_title)
      expect(current_path).to eq root_path

      visit new_admin_conference_program_difficulty_level_path(conference.short_title)
      expect(current_path).to eq root_path

      visit edit_admin_conference_program_difficulty_level_path(conference.short_title, conference.program.difficulty_levels.first)
      expect(current_path).to eq root_path

      visit admin_conference_schedules_path(conference.short_title)
      expect(current_path).to eq admin_conference_schedules_path(conference.short_title)

      create(:schedule, program: conference.program)
      visit admin_conference_schedule_path(conference.short_title, conference.program.schedules.first)
      expect(current_path).to eq root_path

      self_organized_track_schedule = create(:schedule, program: conference.program, track: self_organized_track)
      visit admin_conference_schedule_path(conference.short_title, self_organized_track_schedule)
      expect(current_path).to eq admin_conference_schedule_path(conference.short_title, self_organized_track_schedule)

      visit admin_conference_program_reports_path(conference.short_title)
      expect(current_path).to eq admin_conference_program_reports_path(conference.short_title)

      visit admin_conference_registrations_path(conference.short_title)
      expect(current_path).to eq admin_conference_registrations_path(conference.short_title)

      create(:registration, user: create(:user), conference: conference)
      visit edit_admin_conference_registration_path(conference.short_title, conference.registrations.first)
      expect(current_path).to eq root_path

      visit new_admin_conference_registration_period_path(conference.short_title)
      expect(current_path).to eq root_path

      create(:registration_period, conference: conference)
      visit edit_admin_conference_registration_period_path(conference.short_title)
      expect(current_path).to eq root_path

      visit admin_conference_questions_path(conference.short_title)
      expect(current_path).to eq root_path

      visit admin_conference_sponsorship_levels_path(conference.short_title)
      expect(current_path).to eq root_path

      visit new_admin_conference_sponsorship_level_path(conference.short_title)
      expect(current_path).to eq root_path

      create(:sponsorship_level, conference: conference)
      visit edit_admin_conference_sponsorship_level_path(conference.short_title, conference.sponsorship_levels.first)
      expect(current_path).to eq root_path

      visit admin_conference_sponsors_path(conference.short_title)
      expect(current_path).to eq root_path

      visit new_admin_conference_sponsor_path(conference.short_title)
      expect(current_path).to eq root_path

      create(:sponsor, conference: conference, sponsorship_level: conference.sponsorship_levels.first)
      visit edit_admin_conference_sponsor_path(conference.short_title, conference.sponsors.first)
      expect(current_path).to eq root_path

      visit admin_conference_tickets_path(conference.short_title)
      expect(current_path).to eq root_path

      visit new_admin_conference_ticket_path(conference.short_title)
      expect(current_path).to eq root_path

      create(:ticket, conference: conference)
      visit edit_admin_conference_ticket_path(conference.short_title, conference.tickets.first)
      expect(current_path).to eq root_path

      visit admin_conference_program_tracks_path(conference.short_title)
      expect(current_path).to eq admin_conference_program_tracks_path(conference.short_title)

      visit new_admin_conference_program_track_path(conference.short_title)
      expect(current_path).to eq root_path

      other_track = create(:track, program: conference.program)
      visit admin_conference_program_track_path(conference.short_title, other_track)
      expect(current_path).to eq root_path

      visit edit_admin_conference_program_track_path(conference.short_title, other_track)
      expect(current_path).to eq root_path

      visit admin_conference_program_track_path(conference.short_title, self_organized_track)
      expect(current_path).to eq admin_conference_program_track_path(conference.short_title, self_organized_track)

      visit edit_admin_conference_program_track_path(conference.short_title, self_organized_track)
      expect(current_path).to eq root_path

      visit admin_conference_roles_path(conference.short_title)
      expect(current_path).to eq admin_conference_roles_path(conference.short_title)

      visit admin_conference_emails_path(conference.short_title)
      expect(current_path).to eq root_path

      visit admin_conference_resources_path(conference.short_title)
      expect(current_path).to eq admin_conference_resources_path(conference.short_title)

      visit new_admin_conference_resource_path(conference.short_title)
      expect(current_path).to eq new_admin_conference_resource_path(conference.short_title)

      create(:resource, conference: conference)
      visit edit_admin_conference_resource_path(conference.short_title, conference.resources.first)
      expect(current_path).to eq root_path

      visit admin_revision_history_path
      expect(current_path).to eq root_path
    end
  end
end
