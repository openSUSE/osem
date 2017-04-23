require 'spec_helper'

feature 'Has correct abilities' do
  # It is necessary to use bang version of let to build roles before user
  let(:conference1) { create(:full_conference) } # user is organizer
  let(:conference2) { create(:full_conference) } # user is cfp
  let(:conference3) { create(:full_conference) } # user is info_desk
  let(:conference6) { create(:conference) } # user is organizer, venue is not set by default

  let(:role_organizer_conf1) { Role.find_by(name: 'organizer', resource: conference1) }
  let(:role_organizer_conf6) { Role.find_by(name: 'organizer', resource: conference6) }
  let(:role_cfp) { Role.find_by(name: 'cfp', resource: conference2) }
  let(:role_info_desk) { Role.find_by(name: 'info_desk', resource: conference3) }

  let(:user) { create(:user) }
  let(:user_organizer) { create(:user, role_ids: [role_organizer_conf1.id, role_organizer_conf6.id]) }
  let(:user_cfp) { create(:user, role_ids: [role_cfp.id]) }
  let(:user_info_desk) { create(:user, role_ids: [role_info_desk.id]) }

  scenario 'when user has no role' do
    sign_in user

    visit admin_conference_path(conference1.short_title)
    expect(current_path).to eq root_path
    expect(flash).to eq 'You are not authorized to access this area!'
  end

  scenario 'when user is organizer' do
    sign_in user_organizer

    visit admin_conference_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_path(conference1.short_title))

    expect(page).to have_selector('li.nav-header.nav-header-bigger a', text: 'Dashboard')
    expect(page).to have_link('Basics', href: "/admin/conferences/#{conference1.short_title}/edit")
    expect(page).to have_link('Contact', href: "/admin/conferences/#{conference1.short_title}/contact/edit")
    expect(page).to have_link('Commercials', href: "/admin/conferences/#{conference1.short_title}/commercials")
    expect(page).to have_link('Splashpage', href: "/admin/conferences/#{conference1.short_title}/splashpage")
    expect(page).to have_link('Venue', href: "/admin/conferences/#{conference1.short_title}/venue")
    expect(page).to have_link('Rooms', href: "/admin/conferences/#{conference1.short_title}/venue/rooms")
    expect(page).to have_link('Lodgings', href: "/admin/conferences/#{conference1.short_title}/lodgings")
    expect(page).to have_link('Program', href: "/admin/conferences/#{conference1.short_title}/program")
    expect(page).to have_link('Call for Papers', href: "/admin/conferences/#{conference1.short_title}/program/cfp")
    expect(page).to have_link('Events', href: "/admin/conferences/#{conference1.short_title}/program/events")
    expect(page).to have_link('Tracks', href: "/admin/conferences/#{conference1.short_title}/program/tracks")
    expect(page).to have_link('Event Types', href: "/admin/conferences/#{conference1.short_title}/program/event_types")
    expect(page).to have_link('Difficulty Levels', href: "/admin/conferences/#{conference1.short_title}/program/difficulty_levels")
    expect(page).to have_link('Schedules', href: "/admin/conferences/#{conference1.short_title}/schedules")
    expect(page).to have_link('Reports', href: "/admin/conferences/#{conference1.short_title}/program/reports")
    expect(page).to have_link('Registrations', href: "/admin/conferences/#{conference1.short_title}/registrations")
    expect(page).to have_link('Registration Period', href: "/admin/conferences/#{conference1.short_title}/registration_period")
    expect(page).to have_link('Questions', href: "/admin/conferences/#{conference1.short_title}/questions")
    expect(page).to have_text('Donations')
    expect(page).to have_link('Sponsorship Levels', href: "/admin/conferences/#{conference1.short_title}/sponsorship_levels")
    expect(page).to have_link('Sponsors', href: "/admin/conferences/#{conference1.short_title}/sponsors")
    expect(page).to have_link('Tickets', href: "/admin/conferences/#{conference1.short_title}/tickets")
    expect(page).to have_text('Objectives')
    expect(page).to have_link('Campaigns', href: "/admin/conferences/#{conference1.short_title}/campaigns")
    expect(page).to have_link('Goals', href: "/admin/conferences/#{conference1.short_title}/targets")
    expect(page).to have_link('E-Mails', href: "/admin/conferences/#{conference1.short_title}/emails")
    expect(page).to have_link('Roles', href: "/admin/conferences/#{conference1.short_title}/roles")
    expect(page).to have_link('Resources', href: "/admin/conferences/#{conference1.short_title}/resources")

    visit admin_conference_path(conference6.short_title)
    expect(page).to have_link('Add venue', href: "/admin/conferences/#{conference6.short_title}/venue/new")

    visit edit_admin_conference_path(conference1.short_title)
    expect(current_path).to eq(edit_admin_conference_path(conference1.short_title))

    visit edit_admin_conference_contact_path(conference1.short_title)
    expect(current_path).to eq(edit_admin_conference_contact_path(conference1.short_title))

    visit admin_conference_commercials_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_commercials_path(conference1.short_title))

    visit new_admin_conference_splashpage_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_splashpage_path(conference1.short_title))

    visit edit_admin_conference_splashpage_path(conference1.short_title)
    expect(current_path).to eq(edit_admin_conference_splashpage_path(conference1.short_title))

    visit new_admin_conference_venue_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_venue_path(conference1.short_title))

    conference1.venue = create(:venue)
    visit edit_admin_conference_venue_path(conference1.short_title)
    expect(current_path).to eq(edit_admin_conference_venue_path(conference1.short_title))

    visit admin_conference_venue_rooms_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_venue_rooms_path(conference1.short_title))

    create(:room, venue: conference1.venue)
    visit edit_admin_conference_venue_room_path(conference1.short_title, conference1.venue.rooms.first)
    expect(current_path).to eq(edit_admin_conference_venue_room_path(conference1.short_title, conference1.venue.rooms.first))

    visit admin_conference_lodgings_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_lodgings_path(conference1.short_title))

    visit new_admin_conference_lodging_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_lodging_path(conference1.short_title))

    create(:lodging, conference: conference1)
    visit edit_admin_conference_lodging_path(conference1.short_title, conference1.lodgings.first)
    expect(current_path).to eq(edit_admin_conference_lodging_path(conference1.short_title, conference1.lodgings.first))

    visit new_admin_conference_program_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_program_path(conference1.short_title))

    visit edit_admin_conference_program_path(conference1.short_title)
    expect(current_path).to eq(edit_admin_conference_program_path(conference1.short_title))

    visit new_admin_conference_program_cfp_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_program_cfp_path(conference1.short_title))

    visit edit_admin_conference_program_cfp_path(conference1.short_title)
    expect(current_path).to eq(edit_admin_conference_program_cfp_path(conference1.short_title))

    visit admin_conference_program_events_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_program_events_path(conference1.short_title))

    create(:event, program: conference1.program)
    visit edit_admin_conference_program_event_path(conference1.short_title, conference1.program.events.first)
    expect(current_path).to eq(edit_admin_conference_program_event_path(conference1.short_title, conference1.program.events.first))

    visit admin_conference_program_event_types_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_program_event_types_path(conference1.short_title))

    visit new_admin_conference_program_event_type_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_program_event_type_path(conference1.short_title))

    visit edit_admin_conference_program_event_type_path(conference1.short_title, conference1.program.event_types.first)
    expect(current_path).to eq(edit_admin_conference_program_event_type_path(conference1.short_title, conference1.program.event_types.first))

    visit admin_conference_program_difficulty_levels_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_program_difficulty_levels_path(conference1.short_title))

    visit new_admin_conference_program_difficulty_level_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_program_difficulty_level_path(conference1.short_title))

    visit edit_admin_conference_program_difficulty_level_path(conference1.short_title, conference1.program.difficulty_levels.first)
    expect(current_path).to eq(edit_admin_conference_program_difficulty_level_path(conference1.short_title, conference1.program.difficulty_levels.first))

    visit admin_conference_schedules_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_schedules_path(conference1.short_title))

    create(:schedule, program: conference1.program)
    visit admin_conference_schedule_path(conference1.short_title, conference1.program.schedules.first)
    expect(current_path).to eq(admin_conference_schedule_path(conference1.short_title, conference1.program.schedules.first))

    visit admin_conference_program_reports_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_program_reports_path(conference1.short_title))

    visit admin_conference_registrations_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_registrations_path(conference1.short_title))

    create(:registration, user: create(:user), conference: conference1)
    visit edit_admin_conference_registration_path(conference1.short_title, conference1.registrations.first)
    expect(current_path).to eq(edit_admin_conference_registration_path(conference1.short_title, conference1.registrations.first))

    visit new_admin_conference_registration_period_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_registration_period_path(conference1.short_title))

    create(:registration_period, conference: conference1)
    visit edit_admin_conference_registration_period_path(conference1.short_title)
    expect(current_path).to eq(edit_admin_conference_registration_period_path(conference1.short_title))

    visit admin_conference_questions_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_questions_path(conference1.short_title))

    visit admin_conference_sponsorship_levels_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_sponsorship_levels_path(conference1.short_title))

    visit new_admin_conference_sponsorship_level_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_sponsorship_level_path(conference1.short_title))

    create(:sponsorship_level, conference: conference1)
    visit edit_admin_conference_sponsorship_level_path(conference1.short_title, conference1.sponsorship_levels.first)
    expect(current_path).to eq(edit_admin_conference_sponsorship_level_path(conference1.short_title, conference1.sponsorship_levels.first))

    visit admin_conference_sponsors_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_sponsors_path(conference1.short_title))

    visit new_admin_conference_sponsor_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_sponsor_path(conference1.short_title))

    create(:sponsor, conference: conference1, sponsorship_level: conference1.sponsorship_levels.first)
    visit edit_admin_conference_sponsor_path(conference1.short_title, conference1.sponsors.first)
    expect(current_path).to eq(edit_admin_conference_sponsor_path(conference1.short_title, conference1.sponsors.first))

    visit admin_conference_tickets_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_tickets_path(conference1.short_title))

    visit new_admin_conference_ticket_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_ticket_path(conference1.short_title))

    create(:ticket, conference: conference1)
    visit edit_admin_conference_ticket_path(conference1.short_title, conference1.tickets.first)
    expect(current_path).to eq(edit_admin_conference_ticket_path(conference1.short_title, conference1.tickets.first))

    visit admin_conference_campaigns_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_campaigns_path(conference1.short_title))

    visit new_admin_conference_campaign_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_campaign_path(conference1.short_title))

    create(:campaign, conference: conference1)
    visit edit_admin_conference_campaign_path(conference1.short_title, conference1.campaigns.first)
    expect(current_path).to eq(edit_admin_conference_campaign_path(conference1.short_title, conference1.campaigns.first))

    visit admin_conference_targets_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_targets_path(conference1.short_title))

    visit new_admin_conference_target_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_target_path(conference1.short_title))

    create(:target, conference: conference1)
    visit edit_admin_conference_target_path(conference1.short_title, conference1.targets.first)
    expect(current_path).to eq(edit_admin_conference_target_path(conference1.short_title, conference1.targets.first))

    visit admin_conference_program_tracks_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_program_tracks_path(conference1.short_title))

    visit admin_conference_roles_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_roles_path(conference1.short_title))

    visit admin_conference_emails_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_emails_path(conference1.short_title))

    visit admin_conference_resources_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_resources_path(conference1.short_title))

    visit new_admin_conference_resource_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_resource_path(conference1.short_title))

    create(:resource, conference: conference1)
    visit edit_admin_conference_resource_path(conference1.short_title, conference1.resources.first)
    expect(current_path).to eq(edit_admin_conference_resource_path(conference1.short_title, conference1.resources.first))

    visit admin_revision_history_path
    expect(current_path).to eq(admin_revision_history_path)
  end

  scenario 'when user is cfp' do
    sign_in user_cfp

    visit admin_conference_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_path(conference2.short_title))

    expect(page).to have_selector('li.nav-header.nav-header-bigger a', text: 'Dashboard')
    expect(page).to_not have_link('Basics', href: "/admin/conferences/#{conference2.short_title}/edit")
    expect(page).to have_text('Basics')
    expect(page).to_not have_link('Contact', href: "/admin/conferences/#{conference2.short_title}/contact/edit")
    expect(page).to have_link('Commercials', href: "/admin/conferences/#{conference2.short_title}/commercials")
    expect(page).to_not have_link('Splashpage', href: "/admin/conferences/#{conference2.short_title}/splashpage")
    expect(page).to have_link('Venue', href: "/admin/conferences/#{conference2.short_title}/venue")
    expect(page).to have_link('Rooms', href: "/admin/conferences/#{conference2.short_title}/venue/rooms")
    expect(page).to_not have_link('Lodgings', href: "/admin/conferences/#{conference2.short_title}/lodgings")
    expect(page).to have_link('Program', href: "/admin/conferences/#{conference2.short_title}/program")
    expect(page).to have_link('Call for Papers', href: "/admin/conferences/#{conference2.short_title}/program/cfp")
    expect(page).to have_link('Events', href: "/admin/conferences/#{conference2.short_title}/program/events")
    expect(page).to have_link('Tracks', href: "/admin/conferences/#{conference2.short_title}/program/tracks")
    expect(page).to have_link('Event Types', href: "/admin/conferences/#{conference2.short_title}/program/event_types")
    expect(page).to have_link('Difficulty Levels', href: "/admin/conferences/#{conference2.short_title}/program/difficulty_levels")
    expect(page).to have_link('Schedules', href: "/admin/conferences/#{conference2.short_title}/schedules")
    expect(page).to have_link('Reports', href: "/admin/conferences/#{conference2.short_title}/program/reports")
    expect(page).to_not have_link('Registrations', href: "/admin/conferences/#{conference2.short_title}/registrations")
    expect(page).to_not have_link('Registration Period', href: "/admin/conferences/#{conference2.short_title}/registration_period")
    expect(page).to_not have_link('Questions', href: "/admin/conferences/#{conference2.short_title}/questions")
    expect(page).to_not have_text('Donations')
    expect(page).to_not have_link('Sponsorship Levels', href: "/admin/conferences/#{conference2.short_title}/supporter_levels")
    expect(page).to_not have_link('Sponsors', href: "/admin/conferences/#{conference2.short_title}/sponsors")
    expect(page).to_not have_link('Tickets', href: "/admin/conferences/#{conference2.short_title}/tickets")
    expect(page).to_not have_text('Objectives')
    expect(page).to_not have_link('Campaigns', href: "/admin/conferences/#{conference2.short_title}/campaigns")
    expect(page).to_not have_link('Goals', href: "/admin/conferences/#{conference2.short_title}/targets")
    expect(page).to have_link('E-Mails', href: "/admin/conferences/#{conference2.short_title}/emails")
    expect(page).to have_link('Roles', href: "/admin/conferences/#{conference2.short_title}/roles")
    expect(page).to have_link('Resources', href: "/admin/conferences/#{conference2.short_title}/resources")

    visit edit_admin_conference_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit edit_admin_conference_contact_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_commercials_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_commercials_path(conference2.short_title))

    visit new_admin_conference_splashpage_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit edit_admin_conference_splashpage_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_venue_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    conference2.venue = create(:venue)
    visit edit_admin_conference_venue_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_venue_rooms_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_venue_rooms_path(conference2.short_title))
    create(:room, venue: conference2.venue)
    visit edit_admin_conference_venue_room_path(conference2.short_title, conference2.venue.rooms.first)
    expect(current_path).to eq(edit_admin_conference_venue_room_path(conference2.short_title, conference2.venue.rooms.first))

    visit admin_conference_lodgings_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_lodging_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    create(:lodging, conference: conference2)
    visit edit_admin_conference_lodging_path(conference2.short_title, conference2.lodgings.first)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_program_path(conference2.short_title)
    expect(current_path).to eq(new_admin_conference_program_path(conference2.short_title))

    visit edit_admin_conference_program_path(conference2.short_title)
    expect(current_path).to eq(edit_admin_conference_program_path(conference2.short_title))

    visit new_admin_conference_program_cfp_path(conference2.short_title)
    expect(current_path).to eq(new_admin_conference_program_cfp_path(conference2.short_title))

    visit edit_admin_conference_program_cfp_path(conference2.short_title)
    expect(current_path).to eq(edit_admin_conference_program_cfp_path(conference2.short_title))

    visit admin_conference_program_events_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_program_events_path(conference2.short_title))

    create(:event, program: conference2.program)
    visit edit_admin_conference_program_event_path(conference2.short_title, conference2.program.events.first)
    expect(current_path).to eq(edit_admin_conference_program_event_path(conference2.short_title, conference2.program.events.first))

    visit admin_conference_program_event_types_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_program_event_types_path(conference2.short_title))

    visit new_admin_conference_program_event_type_path(conference2.short_title)
    expect(current_path).to eq(new_admin_conference_program_event_type_path(conference2.short_title))

    visit edit_admin_conference_program_event_type_path(conference2.short_title, conference2.program.event_types.first)
    expect(current_path).to eq(edit_admin_conference_program_event_type_path(conference2.short_title, conference2.program.event_types.first))

    visit admin_conference_program_difficulty_levels_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_program_difficulty_levels_path(conference2.short_title))

    visit new_admin_conference_program_difficulty_level_path(conference2.short_title)
    expect(current_path).to eq(new_admin_conference_program_difficulty_level_path(conference2.short_title))

    visit edit_admin_conference_program_difficulty_level_path(conference2.short_title, conference2.program.difficulty_levels.first)
    expect(current_path).to eq(edit_admin_conference_program_difficulty_level_path(conference2.short_title, conference2.program.difficulty_levels.first))

    visit admin_conference_schedules_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_schedules_path(conference2.short_title))

    create(:schedule, program: conference2.program)
    visit admin_conference_schedule_path(conference2.short_title, conference2.program.schedules.first)
    expect(current_path).to eq(admin_conference_schedule_path(conference2.short_title, conference2.program.schedules.first))

    visit admin_conference_program_reports_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_program_reports_path(conference2.short_title))

    visit admin_conference_registrations_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_registrations_path(conference2.short_title))

    create(:registration, user: create(:user), conference: conference2)
    visit edit_admin_conference_registration_path(conference2.short_title, conference2.registrations.first)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_registration_period_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    create(:registration_period, conference: conference2)
    visit edit_admin_conference_registration_period_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_questions_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_sponsorship_levels_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_sponsorship_level_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    create(:sponsorship_level, conference: conference2)
    visit edit_admin_conference_sponsorship_level_path(conference2.short_title, conference2.sponsorship_levels.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_sponsors_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_sponsor_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    create(:sponsor, conference: conference2, sponsorship_level: conference2.sponsorship_levels.first)
    visit edit_admin_conference_sponsor_path(conference2.short_title, conference2.sponsors.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_tickets_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_ticket_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    create(:ticket, conference: conference2)
    visit edit_admin_conference_ticket_path(conference2.short_title, conference2.tickets.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_campaigns_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_campaign_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    create(:campaign, conference: conference2)
    visit edit_admin_conference_campaign_path(conference2.short_title, conference2.campaigns.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_targets_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_target_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    create(:target, conference: conference2)
    visit edit_admin_conference_target_path(conference2.short_title, conference2.targets.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_program_tracks_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_program_tracks_path(conference2.short_title))

    visit admin_conference_roles_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_roles_path(conference2.short_title))

    visit admin_conference_emails_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_emails_path(conference2.short_title))

    visit admin_conference_resources_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_resources_path(conference2.short_title))

    visit new_admin_conference_resource_path(conference2.short_title)
    expect(current_path).to eq(new_admin_conference_resource_path(conference2.short_title))

    create(:resource, conference: conference2)
    visit edit_admin_conference_resource_path(conference2.short_title, conference2.resources.first)
    expect(current_path).to eq(edit_admin_conference_resource_path(conference2.short_title, conference2.resources.first))

    visit admin_revision_history_path
    expect(current_path).to eq(root_path)
  end

  scenario 'when user is info desk' do
    sign_in user_info_desk

    visit admin_conference_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_path(conference3.short_title))

    expect(page).to have_selector('li.nav-header.nav-header-bigger a', text: 'Dashboard')
    expect(page).to_not have_link('Basics', href: "/admin/conferences/#{conference3.short_title}/edit")
    expect(page).to have_text('Basics')
    expect(page).to_not have_link('Contact', href: "/admin/conferences/#{conference3.short_title}/contact/edit")
    expect(page).to have_link('Commercials', href: "/admin/conferences/#{conference3.short_title}/commercials")
    expect(page).to_not have_link('Splashpage', href: "/admin/conferences/#{conference3.short_title}/splashpage")
    expect(page).to_not have_link('Venue', href: "/admin/conferences/#{conference3.short_title}/venue")
    expect(page).to_not have_link('Rooms', href: "/admin/conferences/#{conference3.short_title}/venue/rooms")
    expect(page).to_not have_link('Lodgings', href: "/admin/conferences/#{conference3.short_title}/lodgings")
    expect(page).to_not have_link('Program', href: "/admin/conferences/#{conference3.short_title}/program")
    expect(page).to_not have_link('Call for Papers', href: "/admin/conferences/#{conference2.short_title}/program/cfp")
    expect(page).to_not have_link('Events', href: "/admin/conferences/#{conference3.short_title}/program/events")
    expect(page).to_not have_link('Tracks', href: "/admin/conferences/#{conference3.short_title}/program/tracks")
    expect(page).to_not have_link('Event Types', href: "/admin/conferences/#{conference3.short_title}/program/event_types")
    expect(page).to_not have_link('Difficulty Levels', href: "/admin/conferences/#{conference3.short_title}/program/difficulty_levels")
    expect(page).to_not have_link('Schedules', href: "/admin/conferences/#{conference3.short_title}/schedules")
    expect(page).to_not have_link('Reports', href: "/admin/conferences/#{conference3.short_title}/program/reports")
    expect(page).to have_link('Registrations', href: "/admin/conferences/#{conference3.short_title}/registrations")
    expect(page).to_not have_link('Registration Period', href: "/admin/conferences/#{conference3.short_title}/registration_period")
    expect(page).to have_link('Questions', href: "/admin/conferences/#{conference3.short_title}/questions")
    expect(page).to_not have_text('Donations')
    expect(page).to_not have_link('Sponsorship Levels', href: "/admin/conferences/#{conference3.short_title}/sponsorship_levels")
    expect(page).to_not have_link('Sponsors', href: "/admin/conferences/#{conference3.short_title}/sponsors")
    expect(page).to_not have_link('Tickets', href: "/admin/conferences/#{conference3.short_title}/tickets")
    expect(page).to_not have_text('Objectives')
    expect(page).to_not have_link('Campaigns', href: "/admin/conferences/#{conference3.short_title}/campaigns")
    expect(page).to_not have_link('Goals', href: "/admin/conferences/#{conference3.short_title}/targets")
    expect(page).to_not have_link('E-Mails', href: "/admin/conferences/#{conference3.short_title}/emails")
    expect(page).to have_link('Roles', href: "/admin/conferences/#{conference3.short_title}/roles")
    expect(page).to have_link('Resources', href: "/admin/conferences/#{conference3.short_title}/resources")

    visit edit_admin_conference_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit edit_admin_conference_contact_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_commercials_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_commercials_path(conference3.short_title))

    visit new_admin_conference_splashpage_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit edit_admin_conference_splashpage_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_venue_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    conference3.venue = create(:venue)
    visit edit_admin_conference_venue_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_venue_rooms_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    create(:room, venue: conference3.venue)
    visit edit_admin_conference_venue_room_path(conference3.short_title, conference3.venue.rooms.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_lodgings_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_lodging_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    create(:lodging, conference: conference3)
    visit edit_admin_conference_lodging_path(conference3.short_title, conference3.lodgings.first)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_program_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit edit_admin_conference_program_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_program_cfp_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit edit_admin_conference_program_cfp_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_program_events_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    create(:event, program: conference3.program)
    visit edit_admin_conference_program_event_path(conference3.short_title, conference3.program.events.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_program_event_types_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_program_event_type_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit edit_admin_conference_program_event_type_path(conference3.short_title, conference3.program.event_types.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_program_difficulty_levels_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_program_difficulty_level_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit edit_admin_conference_program_difficulty_level_path(conference3.short_title, conference3.program.difficulty_levels.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_schedules_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    create(:schedule, program: conference3.program)
    visit admin_conference_schedule_path(conference3.short_title, conference3.program.schedules.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_program_reports_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_registrations_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_registrations_path(conference3.short_title))

    create(:registration, user: create(:user), conference: conference3)
    visit edit_admin_conference_registration_path(conference3.short_title, conference3.registrations.first)
    expect(current_path).to eq(edit_admin_conference_registration_path(conference3.short_title, conference3.registrations.first))

    visit new_admin_conference_registration_period_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    create(:registration_period, conference: conference3)
    visit edit_admin_conference_registration_period_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_questions_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_questions_path(conference3.short_title))

    visit admin_conference_sponsorship_levels_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_sponsorship_level_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    create(:sponsorship_level, conference: conference3)
    visit edit_admin_conference_sponsorship_level_path(conference3.short_title, conference3.sponsorship_levels.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_sponsors_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_sponsor_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    create(:sponsor, conference: conference3, sponsorship_level: conference3.sponsorship_levels.first)
    visit edit_admin_conference_sponsor_path(conference3.short_title, conference3.sponsors.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_tickets_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_ticket_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    create(:ticket, conference: conference3)
    visit edit_admin_conference_ticket_path(conference3.short_title, conference3.tickets.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_campaigns_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_campaign_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    create(:campaign, conference: conference3)
    visit edit_admin_conference_campaign_path(conference3.short_title, conference3.campaigns.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_targets_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_target_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    create(:target, conference: conference3)
    visit edit_admin_conference_target_path(conference3.short_title, conference3.targets.first)
    expect(current_path).to eq(root_path)

    visit admin_conference_program_tracks_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_roles_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_roles_path(conference3.short_title))

    visit admin_conference_emails_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_resources_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_resources_path(conference3.short_title))

    visit new_admin_conference_resource_path(conference3.short_title)
    expect(current_path).to eq(new_admin_conference_resource_path(conference3.short_title))

    create(:resource, conference: conference3)
    visit edit_admin_conference_resource_path(conference3.short_title, conference3.resources.first)
    expect(current_path).to eq(edit_admin_conference_resource_path(conference3.short_title, conference3.resources.first))

    visit admin_revision_history_path
    expect(current_path).to eq(root_path)
  end
end
