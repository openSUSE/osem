require 'spec_helper'

feature 'Has correct abilities' do
  # It is necessary to use bang version of let to build roles before user
  let(:conference1) { create(:full_conference) } # user is organizer
  let(:conference2) { create(:full_conference) } # user is cfp
  let(:conference3) { create(:full_conference) } # user is info_desk
  let(:conference4) { create(:full_conference) } # user is volunteer coordinator
  let(:conference5) { create(:full_conference) } # user has no role

  let(:role_organizer) { Role.find_by(name: 'organizer', resource: conference1) }
  let(:role_cfp) { Role.find_by(name: 'cfp', resource: conference2) }
  let(:role_info_desk) { Role.find_by(name: 'info_desk', resource: conference3) }
  let(:role_volunteers_coordinator) { Role.find_by(name: 'volunteers_coordinator', resource: conference4) }

  let(:user) { create(:user) }
  let(:user_organizer) { create(:user, role_ids: [role_organizer.id]) }
  let(:user_cfp) { create(:user, role_ids: [role_cfp.id]) }
  let(:user_info_desk) { create(:user, role_ids: [role_info_desk.id]) }
  let(:user_volunteers_coordinator) { create(:user, role_ids: [role_volunteers_coordinator.id]) }

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
    expect(page).to have_link('Basics', href: "/admin/conference/#{conference1.short_title}/edit")
    expect(page).to have_link('Contact', href: "/admin/conference/#{conference1.short_title}/contact/edit")
    expect(page).to have_link('Commercials', href: "/admin/conference/#{conference1.short_title}/commercials")
    expect(page).to have_link('Events', href: "/admin/conference/#{conference1.short_title}/program/events")
    expect(page).to have_link('Registrations', href: "/admin/conference/#{conference1.short_title}/registrations")
    expect(page).to have_link('Schedules', href: "/admin/conference/#{conference1.short_title}/schedules")
    expect(page).to have_link('Campaigns', href: "/admin/conference/#{conference1.short_title}/campaigns")
    expect(page).to have_link('Goals', href: "/admin/conference/#{conference1.short_title}/targets")
    expect(page).to have_link('Venue', href: "/admin/conference/#{conference1.short_title}/venue")
    expect(page).to have_link('Rooms', href: "/admin/conference/#{conference1.short_title}/venue/rooms")
    expect(page).to have_link('Lodgings', href: "/admin/conference/#{conference1.short_title}/lodgings")
    expect(page).to have_link('Sponsorship', href: "/admin/conference/#{conference1.short_title}/sponsorship_levels")
    expect(page).to have_link('Sponsors', href: "/admin/conference/#{conference1.short_title}/sponsors")
    expect(page).to have_link('Tickets', href: "/admin/conference/#{conference1.short_title}/tickets")
    expect(page).to have_link('E-Mails', href: "/admin/conference/#{conference1.short_title}/emails")
    expect(page).to have_link('Program', href: "/admin/conference/#{conference1.short_title}/program")
    expect(page).to have_link('Call for Papers', href: "/admin/conference/#{conference1.short_title}/program/cfp")
    expect(page).to have_link('Tracks', href: "/admin/conference/#{conference1.short_title}/program/tracks")
    expect(page).to have_link('Event Types', href: "/admin/conference/#{conference1.short_title}/program/event_types")
    expect(page).to have_link('Difficulty Levels', href: "/admin/conference/#{conference1.short_title}/program/difficulty_levels")
    expect(page).to have_link('Questions', href: "/admin/conference/#{conference1.short_title}/questions")
    expect(page).to have_link('Roles', href: "/admin/conference/#{conference1.short_title}/roles")

    visit edit_admin_conference_path(conference1.short_title)
    expect(current_path).to eq(edit_admin_conference_path(conference1.short_title))

    visit admin_conference_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_path(conference1.short_title))

    visit admin_conference_registrations_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_registrations_path(conference1.short_title))

    visit admin_conference_program_events_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_program_events_path(conference1.short_title))

    visit admin_conference_schedules_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_schedules_path(conference1.short_title))

    visit admin_conference_campaigns_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_campaigns_path(conference1.short_title))

    visit admin_conference_targets_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_targets_path(conference1.short_title))

    visit new_admin_conference_venue_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_venue_path(conference1.short_title))

    conference1.venue = create(:venue)
    visit edit_admin_conference_venue_path(conference1.short_title)
    expect(current_path).to eq(edit_admin_conference_venue_path(conference1.short_title))

    visit admin_conference_sponsorship_levels_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_sponsorship_levels_path(conference1.short_title))

    visit admin_conference_tickets_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_tickets_path(conference1.short_title))

    visit admin_conference_emails_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_emails_path(conference1.short_title))

    visit new_admin_conference_program_cfp_path(conference1.short_title)
    expect(current_path).to eq(new_admin_conference_program_cfp_path(conference1.short_title))

    visit admin_conference_questions_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_questions_path(conference1.short_title))

    visit admin_conference_commercials_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_commercials_path(conference1.short_title))
  end

  scenario 'when user is cfp' do
    sign_in user_cfp

    visit admin_conference_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_path(conference2.short_title))

    expect(page).to have_selector('li.nav-header.nav-header-bigger a', text: 'Dashboard')
    expect(page).to_not have_link('Basics', href: "/admin/conference/#{conference2.short_title}/edit")
    expect(page).to have_text('Basics')
    expect(page).to_not have_link('Contact', href: "/admin/conference/#{conference2.short_title}/contact/edit")
    expect(page).to have_link('Commercials', href: "/admin/conference/#{conference2.short_title}/commercials")
    expect(page).to have_link('Events', href: "/admin/conference/#{conference2.short_title}/program/events")
    expect(page).to_not have_link('Registrations', href: "/admin/conference/#{conference2.short_title}/registrations")
    expect(page).to_not have_link('Schedules', href: "/admin/conference/#{conference2.short_title}/schedules")
    expect(page).to_not have_link('Campaigns', href: "/admin/conference/#{conference2.short_title}/campaigns")
    expect(page).to_not have_link('Goals', href: "/admin/conference/#{conference2.short_title}/targets")
    expect(page).to have_link('Venue', href: "/admin/conference/#{conference2.short_title}/venue")
    expect(page).to have_link('Rooms', href: "/admin/conference/#{conference2.short_title}/venue/rooms")
    expect(page).to_not have_link('Lodgings', href: "/admin/conference/#{conference2.short_title}/lodgings")
    expect(page).to_not have_link('Sponsorship', href: "/admin/conference/#{conference2.short_title}/sponsorship_levels")
    expect(page).to_not have_link('Sponsors', href: "/admin/conference/#{conference2.short_title}/sponsors")
    expect(page).to_not have_link('Supporter Levels', href: "/admin/conference/#{conference2.short_title}/supporter_levels")
    expect(page).to have_link('E-Mails', href: "/admin/conference/#{conference2.short_title}/emails")
    expect(page).to have_link('Program', href: "/admin/conference/#{conference2.short_title}/program")
    expect(page).to have_link('Call for Papers', href: "/admin/conference/#{conference2.short_title}/program/cfp")
    expect(page).to have_link('Tracks', href: "/admin/conference/#{conference2.short_title}/program/tracks")
    expect(page).to have_link('Event Types', href: "/admin/conference/#{conference2.short_title}/program/event_types")
    expect(page).to have_link('Difficulty Levels', href: "/admin/conference/#{conference2.short_title}/program/difficulty_levels")
    expect(page).to_not have_link('Questions', href: "/admin/conference/#{conference2.short_title}/questions")
    expect(page).to have_link('Roles', href: "/admin/conference/#{conference2.short_title}/roles")

    visit edit_admin_conference_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_path(conference2.short_title))

    visit admin_conference_registrations_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_registrations_path(conference2.short_title))

    visit admin_conference_program_events_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_program_events_path(conference2.short_title))

    visit admin_conference_schedules_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_campaigns_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_targets_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit edit_admin_conference_venue_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_sponsorship_levels_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_tickets_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_emails_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_emails_path(conference2.short_title))

    visit new_admin_conference_program_cfp_path(conference2.short_title)
    expect(current_path).to eq(new_admin_conference_program_cfp_path(conference2.short_title))

    visit admin_conference_questions_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_commercials_path(conference2.short_title)
    expect(current_path).to eq(root_path)
  end

  scenario 'when user is info desk' do
    sign_in user_info_desk

    visit admin_conference_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_path(conference3.short_title))

    expect(page).to have_selector('li.nav-header.nav-header-bigger a', text: 'Dashboard')
    expect(page).to_not have_link('Basics', href: "/admin/conference/#{conference2.short_title}/edit")
    expect(page).to have_text('Basics')
    expect(page).to_not have_link('Contact', href: "/admin/conference/#{conference3.short_title}/contact/edit")
    expect(page).to have_link('Commercials', href: "/admin/conference/#{conference3.short_title}/commercials")
    expect(page).to_not have_link('Events', href: "/admin/conference/#{conference3.short_title}/program/events")
    expect(page).to have_link('Registrations', href: "/admin/conference/#{conference3.short_title}/registrations")
    expect(page).to_not have_link('Schedules', href: "/admin/conference/#{conference3.short_title}/schedules")
    expect(page).to_not have_link('Campaigns', href: "/admin/conference/#{conference3.short_title}/campaigns")
    expect(page).to_not have_link('Targets', href: "/admin/conference/#{conference3.short_title}/targets")
    expect(page).to_not have_link('Venue', href: "/admin/conference/#{conference3.short_title}/venue")
    expect(page).to_not have_link('Rooms', href: "/admin/conference/#{conference3.short_title}/venue/rooms")
    expect(page).to_not have_link('Lodgings', href: "/admin/conference/#{conference3.short_title}/lodgings")
    expect(page).to_not have_link('Sponsorship', href: "/admin/conference/#{conference3.short_title}/sponsorship_levels")
    expect(page).to_not have_link('Sponsors', href: "/admin/conference/#{conference3.short_title}/sponsors")
    expect(page).to_not have_link('Supporter Levels', href: "/admin/conference/#{conference3.short_title}/supporter_levels")
    expect(page).to_not have_link('E-Mails', href: "/admin/conference/#{conference3.short_title}/emails")
    expect(page).to_not have_link('Program', href: "/admin/conference/#{conference3.short_title}/program")
    expect(page).to_not have_link('Call for papers', href: "/admin/conference/#{conference3.short_title}/program/cfp")
    expect(page).to_not have_link('Tracks', href: "/admin/conference/#{conference3.short_title}/program/tracks")
    expect(page).to_not have_link('Event types', href: "/admin/conference/#{conference3.short_title}/program/event_types")
    expect(page).to_not have_link('Difficulty levels', href: "/admin/conference/#{conference3.short_title}/program/difficulty_levels")
    expect(page).to have_link('Questions', href: "/admin/conference/#{conference3.short_title}/questions")
    expect(page).to have_link('Roles', href: "/admin/conference/#{conference3.short_title}/roles")

    visit edit_admin_conference_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_path(conference3.short_title))

    visit admin_conference_registrations_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_registrations_path(conference3.short_title))

    visit admin_conference_program_events_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_schedules_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_campaigns_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_targets_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit edit_admin_conference_venue_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_sponsorship_levels_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_tickets_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_emails_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit new_admin_conference_program_cfp_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_questions_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_questions_path(conference3.short_title))

    visit admin_conference_commercials_path(conference3.short_title)
    expect(current_path).to eq(root_path)
  end
end
