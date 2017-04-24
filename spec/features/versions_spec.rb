require 'spec_helper'

feature 'Version' do
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }
  let(:event_with_commercial) { create(:event, program: conference.program) }
  let(:event_commercial) { create(:event_commercial, commercialable: event_with_commercial, url: 'https://www.youtube.com/watch?v=M9bq_alk-sw') }

  before(:each) do
    sign_in organizer
  end

  scenario 'display changes in contact', feature: true, versioning: true, js: true do
    visit edit_admin_conference_contact_path(conference.short_title)
    fill_in 'contact_email', with: 'example@example.com'
    fill_in 'contact_sponsor_email', with: 'sponsor@example.com'
    fill_in 'contact_social_tag', with: 'example'
    fill_in 'contact_googleplus', with: 'http:\\www.google.com'
    click_button 'Update Contact'

    visit admin_revision_history_path
    expect(page).to have_text("#{organizer.name} updated social tag, email, googleplus and sponsor email of contact details in conference #{conference.short_title}")
  end

  scenario 'display changes in program', feature: true, versioning: true, js: true do
    visit edit_admin_conference_program_path(conference.short_title)
    fill_in 'program_rating', with: '4'
    click_button 'Update Program'

    visit admin_revision_history_path
    expect(page).to have_text("#{organizer.name} updated rating of program in conference #{conference.short_title}")
  end

  scenario 'display changes in cfp', feature: true, versioning: true, js: true do
    cfp = create(:cfp, program: conference.program)
    cfp.update_attributes(start_date: (Date.today + 1).strftime('%d/%m/%Y'), end_date: (Date.today + 3).strftime('%d/%m/%Y'))
    cfp.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new cfp in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated start date and end date of cfp in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted cfp in conference #{conference.short_title}")
  end

  scenario 'display changes in registration_period', feature: true, versioning: true, js: true do
    registration_period = create(:registration_period, conference: conference)
    registration_period.update_attributes(start_date: (Date.today + 1).strftime('%d/%m/%Y'), end_date: (Date.today + 3).strftime('%d/%m/%Y'))
    registration_period.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new registration period in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated start date and end date of registration period in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted registration period in conference #{conference.short_title}")
  end

  scenario 'display changes in conference', feature: true, versioning: true, js: true do
    new_conference = create(:conference, title: 'Test Conference')
    organizer.add_role :organizer, new_conference
    new_conference.update_attributes(title: 'New Con', short_title: 'NewCon')

    visit admin_revision_history_path
    select '100', from: 'versionstable_length'
    expect(page).to have_text('Someone (probably via the console) created new conference New Con')
    expect(page).to have_text('Someone (probably via the console) created new event type Talk in conference NewCon')
    expect(page).to have_text('Someone (probably via the console) created new event type Workshop in conference NewCon')
    expect(page).to have_text('Someone (probably via the console) updated title and short title of conference New Con')
  end

  scenario 'display changes in event_type', feature: true, versioning: true, js: true do
    event_type = create(:event_type, program: conference.program, name: 'Discussion')
    event_type.update_attributes(length: 90, maximum_abstract_length: 10000)
    event_type.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new event type Discussion in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated length and maximum abstract length of event type Discussion in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted event type Discussion in conference #{conference.short_title}")
  end

  scenario 'display changes in lodging', feature: true, versioning: true, js: true do
    lodging = create(:lodging, conference: conference, name: 'Hotel XYZ')
    lodging.update_attributes(description: 'Nice view,close to venue', website_link: 'http://www.example.com')
    lodging.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new lodging Hotel XYZ in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated description and website link of lodging Hotel XYZ in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted lodging Hotel XYZ in conference #{conference.short_title}")
  end

  scenario 'display changes in role', feature: true, versioning: true, js: true do
    visit edit_admin_conference_role_path(conference.short_title, 'cfp')
    fill_in 'role_description', with: 'For the members of the call for papers team'
    click_button 'Update Role'

    visit admin_revision_history_path(conference_id: conference.short_title)
    expect(page).to have_text("#{organizer.name} updated description of role cfp in conference #{conference.short_title}")
  end

  scenario 'display changes in room', feature: true, versioning: true, js: true do
    venue = create(:venue, conference: conference)
    room = create(:room, venue: venue, name: 'Auditorium')
    room.update_attributes(size: 120)
    room.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new room Auditorium in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated size of room Auditorium in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted room Auditorium in conference #{conference.short_title}")
  end

  scenario 'display changes in sponsor', feature: true, versioning: true, js: true do
    conference.sponsorship_levels << create_list(:sponsorship_level, 2, conference: conference)
    sponsor = create(:sponsor, conference: conference, name: 'SUSE', sponsorship_level: conference.sponsorship_levels.first)
    sponsor.update_attributes(website_url: 'https://www.suse.com/company/history', sponsorship_level: conference.sponsorship_levels.second)
    sponsor.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new sponsor SUSE in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated website url and sponsorship level of sponsor SUSE in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted sponsor SUSE in conference #{conference.short_title}")
  end

  scenario 'display changes in sponsorship_level', feature: true, versioning: true, js: true do
    sponsorship_level = create(:sponsorship_level, conference: conference)
    sponsorship_level.update_attributes(title: 'Gold')
    sponsorship_level.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new sponsorship level Gold in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated title of sponsorship level Gold in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted sponsorship level Gold in conference #{conference.short_title}")
  end

  scenario 'display changes in ticket', feature: true, versioning: true, js: true do
    ticket = create(:ticket, conference: conference, title: 'Gold')
    ticket.update_attributes(price: 50, description: 'Premium Ticket')
    ticket.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new ticket Gold in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated price cents and description of ticket Gold in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted ticket Gold in conference #{conference.short_title}")
  end

  scenario 'display changes in track', feature: true, versioning: true, js: true do
    track = create(:track, program: conference.program, name: 'Distribution')
    track.update_attributes(description: 'Events about Linux distributions')
    track.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new track Distribution in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated description of track Distribution in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted track Distribution in conference #{conference.short_title}")
  end

  scenario 'display changes in venue', feature: true, versioning: true, js: true do
    venue = create(:venue, conference: conference, name: 'Example University')
    venue.update_attributes(website: 'www.example.com new', description: 'Just another beautiful venue')
    venue.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new venue Example University in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated website and description of venue Example University in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted venue Example University in conference #{conference.short_title}")
  end

  scenario 'display changes in event', feature: true, versioning: true, js: true do
    visit new_conference_program_proposal_path(conference_id: conference.short_title)
    fill_in 'event_title', with: 'ABC'
    fill_in 'event_abstract', with: 'Lorem ipsum abstract'
    select('Talk - 30 min', from: 'event[event_type_id]')
    click_button 'Create Proposal'

    click_link 'Edit'
    fill_in 'event_subtitle', with: 'My event subtitle'
    select('Easy', from: 'event[difficulty_level_id]')
    click_button 'Update Proposal'

    visit admin_conference_program_events_path(conference.short_title)
    click_button 'New'
    click_link 'Reject event'

    visit conference_program_proposals_path(conference_id: conference.short_title)
    click_link 'Re-Submit'

    visit admin_conference_program_events_path(conference.short_title)
    click_button 'New'
    click_link 'Accept event'

    visit conference_program_proposals_path(conference_id: conference.short_title)
    click_link 'Confirm'

    visit admin_conference_program_events_path(conference.short_title)
    click_button 'Confirmed'
    click_link 'Cancel event'

    visit admin_revision_history_path
    expect(page).to have_text("#{organizer.name} submitted new event ABC in conference #{conference.short_title}")
    expect(page).to have_text("#{organizer.name} updated difficulty level and subtitle of event ABC in conference #{conference.short_title}")
    expect(page).to have_text("#{organizer.name} rejected event ABC in conference #{conference.short_title}")
    expect(page).to have_text("#{organizer.name} resubmitted event ABC in conference #{conference.short_title}")
    expect(page).to have_text("#{organizer.name} accepted event ABC in conference #{conference.short_title}")
    expect(page).to have_text("#{organizer.name} confirmed event ABC in conference #{conference.short_title}")
    expect(page).to have_text("#{organizer.name} canceled event ABC in conference #{conference.short_title}")
  end

  scenario 'display changes in difficulty levels', feature: true, versioning: true, js: true do
    difficulty_level = create(:difficulty_level, program: conference.program, title: 'Expert')
    difficulty_level.update_attributes(description: 'Only for Experts')
    difficulty_level.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new difficulty level Expert in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated description of difficulty level Expert in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted difficulty level Expert in conference #{conference.short_title}")
  end

  scenario 'display changes in splashpages', feature: true, versioning: true, js: true do
    visit admin_conference_splashpage_path(conference.short_title)
    click_link 'Create Splashpage'
    click_button 'Save Splashpage'

    click_link 'Edit'
    uncheck('Display program')
    uncheck('Display call for papers information on splashpage, while cfp is open')
    uncheck('Display venue')
    uncheck('Display tickets')
    uncheck('Display the lodgings')
    uncheck('Display sponsors')
    uncheck('Display social media')
    check('Make splash page public?')
    click_button 'Save Splashpage'

    click_link 'Delete'
    visit admin_revision_history_path
    expect(page).to have_text("#{organizer.name} created new splashpage in conference #{conference.short_title}")
    expect(page).to have_text("#{organizer.name} updated public, include program, include cfp, include venue, include tickets, include lodgings,
      include sponsors and include social media of splashpage in conference #{conference.short_title}")
    expect(page).to have_text("#{organizer.name} deleted splashpage in conference #{conference.short_title}")
  end

  scenario 'displays users subscribe/unsubscribe to conferences', feature: true, versioning: true, js: true do
    visit root_path
    click_link 'Subscribe'
    click_link 'Unsubscribe'
    PaperTrail::Version.last.reify.save!
    PaperTrail::Version.last.item.destroy!

    visit admin_revision_history_path
    expect(page).to have_text("#{organizer.name} subscribed to conference #{conference.title}")
    expect(page).to have_text("#{organizer.name} unsubscribed from conference #{conference.title}")
    expect(page).to have_text("Someone (probably via the console) subscribed #{organizer.name} to conference #{conference.title}")
    expect(page).to have_text("Someone (probably via the console) unsubscribed #{organizer.name} from conference #{conference.title}")
  end

  scenario 'display changes in conference commercials', feature: true, versioning: true, js: true do
    conference_commercial = create(:conference_commercial, commercialable: conference)
    conference_commercial.update_attributes(url: 'https://www.youtube.com/watch?v=VNkDJk5_9eU')
    conference_commercial.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new commercial in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated url of commercial in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted commercial in conference #{conference.short_title}")
  end

  scenario 'display changes in event commercials', feature: true, versioning: true, js: true do
    event_commercial
    event_commercial.update_attributes(url: 'https://www.youtube.com/watch?v=VNkDJk5_9eU')
    event_commercial.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new commercial in event #{event_with_commercial.title} in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated url of commercial in event #{event_with_commercial.title} in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted commercial in event #{event_with_commercial.title} in conference #{conference.short_title}")
  end

  scenario 'display changes in event commercials in event history', feature: true, versioning: true, js: true do
    event_without_commercial = create(:event, program: conference.program)
    event_commercial

    visit admin_conference_program_event_path(conference.short_title, event_with_commercial)
    click_link 'History'
    expect(page).to have_text('Someone (probably via the console) created new commercial')
    visit admin_conference_program_event_path(conference.short_title, event_without_commercial)
    click_link 'History'
    expect(event_commercial.id).not_to eq event_commercial.commercialable_id
    expect(event_without_commercial.id).to eq event_commercial.id
    expect(page).to have_no_text('Someone (probably via the console) created new commercial')
  end

  scenario 'display changes in users_role', feature: true, versioning: true, js: true do
    user = create(:user)
    user.add_role :cfp, conference
    user.remove_role :cfp, conference

    visit admin_revision_history_path
    expect(page).to have_text("added role cfp to user #{user.name} in conference #{conference.short_title}")
    expect(page).to have_text("removed role cfp from user #{user.name} in conference #{conference.short_title}")
  end

  scenario 'display changes in email settings', feature: true, versioning: true, js: true do
    conference.email_settings.update_attributes(registration_subject: 'xxxxx', registration_body: 'yyyyy', accepted_subject: 'zzzzz')

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) updated registration subject, registration body and accepted subject
    of email settings in conference #{conference.short_title}")
  end

  scenario 'display changes in conference registrations', feature: true, versioning: true, js: true do
    Registration.create(user: organizer, conference: conference)
    Registration.last.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) registered #{organizer.name} to conference #{conference.title}")
    expect(page).to have_text("Someone (probably via the console) unregistered #{organizer.name} from conference #{conference.title}")
  end

  scenario 'display changes in event registration', feature: true, versioning: true, js: true do
    create(:event, program: conference.program, title: 'My first event')
    registration = Registration.create(user: organizer, conference: conference)
    event = create(:event, program: conference.program, title: 'My second event')
    EventsRegistration.create(registration: registration, event: event)
    EventsRegistration.first.update_attributes(attended: true)
    EventsRegistration.last.destroy
    # Here registration is deleted to ensure the event registration related change still displays the asociated user's name
    registration.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) registered #{organizer.name} to event My second event in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated attended of #{organizer.name}'s registration for event #{event.title} in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) unregistered #{organizer.name} from event #{event.title} in conference #{conference.short_title}")
  end

  scenario 'display changes in target', feature: true, versioning: true, js: true do
    target = create(:target, conference: conference)
    target.update_attributes(due_date: Date.today, target_count: 1000)
    target.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new target 1000 Submissions by #{Date.today} in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated due date and target count of target 1000 Submissions by #{Date.today} in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted target 1000 Submissions by #{Date.today} in conference #{conference.short_title}")
  end

  scenario 'display changes in comment', feature: true, versioning: true, js: true do
    create(:event, program: conference.program, title: 'My first event')
    event = create(:event, program: conference.program, title: 'My second event')
    visit admin_conference_program_event_path(conference_id: conference.short_title, id: event.id)
    click_link 'Comments (0)'
    fill_in 'comment_body', with: 'Sample comment'
    click_button 'Add Comment'
    Comment.last.destroy
    PaperTrail::Version.last.reify.save

    visit admin_revision_history_path
    expect(page).to have_text("#{organizer.name} commented on event My second event in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted #{organizer.name}'s comment on event #{event.title} in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) re-added #{organizer.name}'s comment on event #{event.title}  in conference #{conference.short_title}")
  end

  scenario 'display changes in vote', feature: true, versioning: true, js: true do
    conference.program.rating = 1
    create(:event, program: conference.program, title: 'My first event')
    event = create(:event, program: conference.program, title: 'My second event')
    create(:vote, user: organizer, event: event)
    Vote.last.destroy
    PaperTrail::Version.last.reify.save

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) voted on event My second event in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted #{organizer.name}'s vote on event #{event.title} in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) re-added #{organizer.name}'s vote on event #{event.title}  in conference #{conference.short_title}")
  end

  scenario 'display changes in campaign', feature: true, versioning: true, js: true do
    campaign = create(:campaign, conference: conference, name: 'Test Campaign', utm_campaign: 'campaign')
    campaign.update_attributes(utm_source: 'source', utm_medium: 'medium', utm_term: 'term', utm_content: 'content')
    campaign.destroy

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) created new campaign Test Campaign in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) updated utm source, utm medium, utm term and utm content of campaign Test Campaign in conference #{conference.short_title}")
    expect(page).to have_text("Someone (probably via the console) deleted campaign Test Campaign in conference #{conference.short_title}")
  end

  scenario 'display password reset requests', feature: true, versioning: true, js: true do
    user = create(:user)
    user.send_reset_password_instructions

    visit admin_revision_history_path
    expect(page).to have_text("Someone requested password reset of user #{user.name}")
  end

  scenario 'display user signups', feature: true, versioning: true, js: true do
    create(:user, name: 'testname')

    visit admin_revision_history_path
    expect(page).to have_text('testname signed up')
  end

  scenario 'display updates to user', feature: true, versioning: true, js: true do
    user = create(:user)
    user.update_attributes(nickname: 'testnick', affiliation: 'openSUSE')

    visit admin_revision_history_path
    expect(page).to have_text("Someone (probably via the console) updated  nickname and affiliation of user #{user.name}")
  end
end
