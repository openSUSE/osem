require 'spec_helper'

feature 'Has correct abilities' do
  # It is necessary to use bang version of let to build roles before user
  let(:conference1) { create(:conference) } # user is organizer
  let(:conference2) { create(:conference) } # user is cfp
  let(:conference3) { create(:conference) } # user is info_desk
  let(:conference4) { create(:conference) } # user is volunteer coordinator
  let(:conference5) { create(:conference) } # user has no role

  let(:role_organizer) { create(:role, name: 'organizer', resource: conference1) }
  let(:role_cfp) { create(:role, name: 'cfp', resource: conference2) }
  let(:role_info_desk) { create(:role, name: 'info_desk', resource: conference3) }
  let(:role_volunteer_coordinator) { create(:role, name: 'volunteer_coordinator', resource: conference4) }

  let(:user) { create(:user, role_ids: [role_organizer.id, role_cfp.id, role_info_desk.id, role_volunteer_coordinator.id]) }

  scenario 'when user is organizer' do
    sign_in user
    visit admin_conference_path(conference1.short_title)

    expect(page.has_content?('Basics')).to be true
    expect(page.has_content?('Dashboard')).to be true
    expect(page.has_content?('Registrations')).to be true
    expect(page.has_content?('Events')).to be true
    expect(page.has_content?('Schedule')).to be true
    expect(page.has_content?('Campaigns')).to be true
    expect(page.has_content?('Targets')).to be true
    expect(page.has_content?('Venue')).to be true
    expect(page.has_content?('Sponsorship')).to be true
    expect(page.has_content?('Supporter Levels')).to be true
    expect(page.has_content?('E-Mails')).to be true
    expect(page.has_content?('Call for papers')).to be true
    expect(page.has_content?('Questions')).to be true
    expect(page.has_content?('Commercials')).to be true

    visit edit_admin_conference_path(conference1.short_title)
    expect(current_path).to eq(edit_admin_conference_path(conference1.short_title))

    visit admin_conference_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_path(conference1.short_title))

    visit admin_conference_registrations_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_registrations_path(conference1.short_title))

    visit admin_conference_events_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_events_path(conference1.short_title))

    visit admin_conference_schedule_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_schedule_path(conference1.short_title))

    visit admin_conference_campaigns_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_campaigns_path(conference1.short_title))

    visit admin_conference_targets_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_targets_path(conference1.short_title))

    visit admin_conference_venue_info_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_venue_info_path(conference1.short_title))

    visit admin_conference_sponsorship_levels_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_sponsorship_levels_path(conference1.short_title))

    visit admin_conference_supporter_levels_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_supporter_levels_path(conference1.short_title))

    visit admin_conference_emails_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_emails_path(conference1.short_title))

    visit admin_conference_callforpapers_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_callforpapers_path(conference1.short_title))

    visit admin_conference_questions_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_questions_path(conference1.short_title))

    visit admin_conference_commercials_path(conference1.short_title)
    expect(current_path).to eq(admin_conference_commercials_path(conference1.short_title))
  end

  scenario 'when user is cfp' do
    sign_in user
    visit admin_conference_path(conference2.short_title)

    expect(page.has_content?('Basics')).to be true
    expect(page.has_content?('Dashboard')).to be true
#     expect(page.has_content?('Registrations')).to be false
    expect(page.has_content?('Events')).to be true
    expect(page.has_content?('Schedule')).to be true
#     expect(page.has_content?('Campaigns')).to be false
    expect(page.has_content?('Targets')).to be false
    expect(page.has_content?('Venue')).to be true
    expect(page.has_content?('Sponsorship')).to be false
    expect(page.has_content?('Supporter Levels')).to be false
    expect(page.has_content?('E-Mails')).to be true
    expect(page.has_content?('Call for papers')).to be true
    expect(page.has_content?('Questions')).to be false
    expect(page.has_content?('Commercials')).to be true

    visit edit_admin_conference_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_path(conference2.short_title))

    visit admin_conference_registrations_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_events_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_events_path(conference2.short_title))

    visit admin_conference_schedule_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_schedule_path(conference2.short_title))

    visit admin_conference_campaigns_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_targets_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_venue_info_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_sponsorship_levels_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_supporter_levels_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_emails_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_emails_path(conference2.short_title))

    visit admin_conference_callforpapers_path(conference2.short_title)
    expect(current_path).to eq(admin_conference_callforpapers_path(conference2.short_title))

    visit admin_conference_questions_path(conference2.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_commercials_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_commercials_path(conference3.short_title))
  end

  scenario 'when user is info desk' do
    sign_in user
    visit admin_conference_path(conference3.short_title)

    expect(page.has_content?('Basics')).to be true
    expect(page.has_content?('Dashboard')).to be true
    expect(page.has_content?('Registrations')).to be true
    expect(page.has_content?('Events')).to be false
    expect(page.has_content?('Schedule')).to be false
#     expect(page.has_content?('Campaigns')).to be false
    expect(page.has_content?('Targets')).to be false
    expect(page.has_content?('Venue')).to be false
    expect(page.has_content?('Sponsorship')).to be false
    expect(page.has_content?('Supporter Levels')).to be false
    expect(page.has_content?('E-Mails')).to be false
    expect(page.has_content?('Call for papers')).to be false
    expect(page.has_content?('Questions')).to be true
#     expect(page.has_content?('Commercials')).to be true

    visit edit_admin_conference_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_path(conference3.short_title))

    visit admin_conference_registrations_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_registrations_path(conference3.short_title))

    visit admin_conference_events_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_schedule_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_campaigns_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_targets_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_venue_info_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_sponsorship_levels_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_supporter_levels_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_emails_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_callforpapers_path(conference3.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_questions_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_questions_path(conference3.short_title))

    visit admin_conference_commercials_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_commercials_path(conference3.short_title))

  end

  scenario 'when user is volunteer coordinator' do
    sign_in user
    visit admin_conference_path(conference4.short_title)

    expect(page.has_content?('Basics')).to be true
    expect(page.has_content?('Dashboard')).to be true
#     expect(page.has_content?('Registrations')).to be false
    expect(page.has_content?('Events')).to be false
    expect(page.has_content?('Schedule')).to be false
#     expect(page.has_content?('Campaigns')).to be false
    expect(page.has_content?('Targets')).to be false
    expect(page.has_content?('Venue')).to be false
    expect(page.has_content?('Sponsorship')).to be false
    expect(page.has_content?('Supporter Levels')).to be false
    expect(page.has_content?('E-Mails')).to be false
    expect(page.has_content?('Call for papers')).to be false
    expect(page.has_content?('Questions')).to be false
    expect(page.has_content?('Commercials')).to be true

    visit edit_admin_conference_path(conference4.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_path(conference4.short_title)
    expect(current_path).to eq(admin_conference_path(conference4.short_title))

    visit admin_conference_registrations_path(conference4.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_events_path(conference4.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_schedule_path(conference4.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_campaigns_path(conference4.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_targets_path(conference4.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_venue_info_path(conference4.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_sponsorship_levels_path(conference4.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_supporter_levels_path(conference4.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_emails_path(conference4.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_callforpapers_path(conference4.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_questions_path(conference4.short_title)
    expect(current_path).to eq(root_path)

    visit admin_conference_commercials_path(conference3.short_title)
    expect(current_path).to eq(admin_conference_commercials_path(conference3.short_title))
  end
end
