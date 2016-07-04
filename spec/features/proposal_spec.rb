require 'spec_helper'

feature Event do
  let!(:conference) { create(:conference) }
  let!(:registration_period) { create(:registration_period, conference: conference, start_date: Date.current) }
  let!(:cfp) { create(:cfp, program_id: conference.program.id) }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, email: 'admin@example.com', role_ids: [organizer_role.id]) }
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

    scenario 'rejects a proposal', feature: true, js: true do
      visit admin_conference_program_events_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true

      click_button 'New'
      click_link "reject_event_#{@event.id}"
      expect(flash).to eq('Event rejected!')
      @event.reload
      expect(@event.state).to eq('rejected')
    end

    scenario 'accepts a proposal', feature: true, js: true do
      visit admin_conference_program_events_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true

      click_button 'New'
      click_link "accept_event_#{@event.id}"
      expect(flash).to eq('Event accepted!')
      expect(page.has_content?('Unconfirmed')).to be true
      @event.reload
      expect(@event.state).to eq('unconfirmed')
    end

    scenario 'restarts review of a proposal', feature: true, js: true do
      @event.reject!(@options)
      visit admin_conference_program_events_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true

      click_button 'Rejected'
      click_link "restart_event_#{@event.id}"
      expect(flash).to eq('Review started!')
      @event.reload
      expect(@event.state).to eq('new')
    end
  end

  context 'as a participant' do
    before(:each) do
      @event.accept!(@options)
    end

    scenario 'not signed_in user submits proposal' do
      expected_count_event = Event.count + 1
      expected_count_user = User.count + 1

      visit new_conference_program_proposal_path(conference.short_title)

      fill_in 'user_username', with: 'Test User'
      fill_in 'user_email', with: 'testuser@osem.io'
      fill_in 'password_inline', with: 'testuserpassword'
      fill_in 'user_password_confirmation', with: 'testuserpassword'

      fill_in 'event_title', with: 'Example Proposal'
      select('Example Event Type', from: 'event[event_type_id]')
      fill_in 'event_abstract', with: 'Lorem ipsum abstract'

      click_button 'Create Proposal'
      expect(flash).to eq('Proposal was successfully submitted.')

      expect(Event.count).to eq(expected_count_event)
      expect(User.count).to eq(expected_count_user)
    end

    scenario 'update a proposal' do
      conference = create(:conference)
      proposal = create(:event, program: conference.program)

      sign_in proposal.submitter

      visit edit_conference_program_proposal_path(proposal.program.conference.short_title, proposal)

      fill_in 'event_subtitle', with: 'My event subtitle'
      select('Easy', from: 'event[difficulty_level_id]')

      click_button 'Update Proposal'
      expect(flash).to eq('Proposal was successfully updated.')
    end

    scenario 'signed_in user submits a valid proposal', feature: true, js: true do
      sign_in participant_without_bio
      expected_count = Event.count + 1
      visit conference_program_proposal_index_path(conference.short_title)
      click_link 'New Proposal'

      fill_in 'event_title', with: 'Example Proposal'

      select('Example Event Type', from: 'event[event_type_id]')

      fill_in 'event_abstract', with: 'Lorem ipsum abstract'
      click_link 'description_link'
      fill_in 'event_description', with: 'Lorem ipsum description'

      click_button 'Create Proposal'
      expect(flash).to eq('Proposal was successfully submitted.')

      expect(current_path).to eq(conference_program_proposal_index_path(conference.short_title))
      expect(Event.count).to eq(expected_count)
    end

    scenario 'confirms a proposal', feature: true, js: true do
      sign_in participant
      visit conference_program_proposal_index_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true
      expect(@event.state).to eq('unconfirmed')
      click_link "confirm_proposal_#{@event.id}"
      expect(flash).
        to eq('The proposal was confirmed. Please register to attend the conference.')
      expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
      @event.reload
      expect(@event.state).to eq('confirmed')
    end

    scenario 'withdraw a proposal', feature: true, js: true do
      sign_in participant
      @event.confirm!
      visit conference_program_proposal_index_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true
      click_link "delete_proposal_#{@event.id}"
      expect(flash).to eq('Proposal was successfully withdrawn.')
      @event.reload
      expect(@event.state).to eq('withdrawn')
    end
  end
end
