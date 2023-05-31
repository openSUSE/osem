# frozen_string_literal: true

require 'spec_helper'

feature Event do
  let!(:conference) { create(:conference) }
  let!(:registration_period) { create(:registration_period, conference: conference, start_date: Date.current) }
  let!(:cfp) { create(:cfp, program_id: conference.program.id) }
  let!(:organizer) { create(:organizer, resource: conference) }
  let!(:participant) { create(:user) }
  let!(:participant_without_bio) { create(:user, biography: '') }

  before(:each) do
    @options = {}
    @options[:send_mail] = 'false'
    @event = create(:event, program: conference.program, title: 'Example Proposal')
    @event.event_users.create(user: participant, event_role: 'submitter')
    @event.event_users.create(user: participant, event_role: 'speaker')
  end

  after(:each) do
    sign_out
  end

  context 'as an conference organizer' do
    before(:each) do
      sign_in organizer
    end

    scenario 'adds a proposal', feature: true, js: true do
      visit admin_conference_program_events_path(conference.short_title)
      click_on 'Add Event'
      fill_in 'Title', with: 'Organizer-Created Proposal'
      fill_in 'Abstract', with: 'This proposal was created by an organizer.'
      click_button 'Create Proposal'
      expect(flash).to eq('Event was successfully submitted.')
    end

    scenario 'rejects a proposal', feature: true, js: true do
      visit admin_conference_program_events_path(conference.short_title)
      expect(page).to have_content 'Example Proposal'

      click_on 'New'
      click_link 'Reject'
      expect(page).to have_content 'Event rejected!'
      @event.reload
      expect(@event.state).to eq('rejected')
    end

    scenario 'accepts a proposal', feature: true, js: true do
      visit admin_conference_program_events_path(conference.short_title)
      expect(page).to have_content 'Example Proposal'

      click_on 'New'
      click_link 'Accept'
      expect(page).to have_content 'Event accepted!'
      expect(page).to have_content 'Unconfirmed'
      @event.reload
      expect(@event.state).to eq('unconfirmed')
    end

    scenario 'restarts review of a proposal', feature: true, js: true do
      @event.reject!(@options)
      visit admin_conference_program_events_path(conference.short_title)
      expect(page).to have_content 'Example Proposal'

      click_on 'Rejected'
      click_link 'Start review'
      expect(page).to have_content 'Review started!'
      @event.reload
      expect(@event.state).to eq('new')
    end
  end

  context 'as a participant' do
    before(:each) do
      @event.accept!(@options)
    end

    scenario 'not signed_in user submits proposal', js: true do
      expected_count_event = Event.count + 1
      expected_count_user = User.count + 1

      visit new_conference_program_proposal_path(conference.short_title)
      within('#signup') do
        fill_in 'user_username', with: 'Test User'
        fill_in 'user_email', with: 'testuser@osem.io'
        fill_in 'user_password', with: 'testuserpassword'
        fill_in 'user_password_confirmation', with: 'testuserpassword'
      end
      fill_in 'event_title', with: 'Example Proposal'

      expect(page).to have_selector '.in', text: 'Presentation in lecture format'
      expect(page).to have_text 'Abstracts must be between 0 and 500 words.'
      select('Example Event Type', from: 'event[event_type_id]')
      expect(page).to have_selector '.in', text: 'This event type is an example.'
      expect(page).to have_text 'Abstracts must be between 0 and 123 words.'

      expect(page).to have_text('You have used 0 words')
      fill_in 'event_abstract', with: 'Lorem ipsum abstract'
      expect(page).to have_text('You have used 3 words')

      click_button 'Create Proposal'
      page.find('#flash')
      expect(page).to have_content 'Proposal was successfully submitted.'

      expect(Event.count).to eq(expected_count_event)
      expect(User.count).to eq(expected_count_user)
    end

    scenario 'edit proposal without cfp' do
      conference = create(:conference)
      proposal = create(:event, program: conference.program)

      sign_in proposal.submitter

      visit edit_conference_program_proposal_path(proposal.program.conference.short_title, proposal)

      expect(page).to have_content 'Proposal Information'
    end

    scenario 'update a proposal', js: true do
      conference = create(:conference)
      create :event_type, program:                 conference.program,
                          title:                   'Five to Ten Words',
                          description:             'This has a nonzero minimum.',
                          minimum_abstract_length: 5,
                          maximum_abstract_length: 10
      create :track, program:     conference.program,
                     name:        'Example Track',
                     description: 'This track is an *example*.'
      create(:cfp, program: conference.program)
      proposal = create(:event, program: conference.program, abstract: 'Three word abstract')

      sign_in proposal.submitter

      visit edit_conference_program_proposal_path(proposal.program.conference.short_title, proposal)

      fill_in 'event_subtitle', with: 'My event subtitle'

      select 'Example Track', from: 'Track'
      expect(page).to have_selector '.in', text: 'This track is an example.'

      select('Easy', from: 'event[difficulty_level_id]')
      expect(page).to have_selector '.in', text: 'Events are understandable for everyone without knowledge of the topic.'

      expect(page).to have_selector '.in', text: 'This event type is an example.'
      expect(page).to have_text 'Abstracts must be between 0 and 123 words.'
      select 'Five to Ten Words', from: 'Type'
      expect(page).to have_selector '.in', text: 'This has a nonzero minimum.'
      expect(page).to have_text 'Abstracts must be between 5 and 10 words.'

      expect(page).to have_text('You have used 3 words')
      fill_in 'event_abstract', with: 'This abstract has five words.'
      expect(page).to have_text('You have used 5 words')

      click_button 'Update Proposal'
      page.find('#flash')
      expect(page).to have_content 'Proposal was successfully updated.'
    end

    scenario 'signed_in user submits a valid proposal', feature: true, js: true do
      sign_in participant_without_bio
      expected_count = Event.count + 1

      visit conference_program_proposals_path(conference.short_title)
      click_link 'New Proposal'

      fill_in 'event_title', with: 'Example Proposal'
      select('Example Event Type', from: 'event[event_type_id]')
      expect(page).to have_selector '.in', text: 'This event type is an example.'

      fill_in 'event_abstract', with: 'Lorem ipsum abstract'
      expect(page).to have_text('You have used 3 words')

      click_link 'Do you require something special for your event?'
      fill_in 'event_description', with: 'Lorem ipsum description'

      click_button 'Create Proposal'

      page.find('#flash')
      expect(page).to have_content 'Proposal was successfully submitted.'
      expect(current_path).to eq(conference_program_proposals_path(conference.short_title))
      expect(Event.count).to eq(expected_count)
    end

    scenario 'confirms a proposal', feature: true, js: true do
      sign_in participant
      visit conference_program_proposals_path(conference.short_title)
      expect(page).to have_content 'Example Proposal'
      expect(@event.state).to eq('unconfirmed')
      click_link "confirm_proposal_#{@event.id}"
      expect(page).to have_content 'The proposal was confirmed. Please register to attend the conference.'
      expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
      @event.reload
      expect(@event.state).to eq('confirmed')
    end

    scenario 'withdraw a proposal', feature: true, js: true do
      sign_in participant
      @event.confirm!
      visit conference_program_proposals_path(conference.short_title)
      expect(page).to have_content 'Example Proposal'
      click_link "delete_proposal_#{@event.id}"
      page.accept_alert
      page.find('#flash')
      expect(page).to have_content 'Proposal was successfully withdrawn.'
      @event.reload
      expect(@event.state).to eq('withdrawn')
    end
  end
end
