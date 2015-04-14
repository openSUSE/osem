require 'spec_helper'

feature Event do
  let!(:conference) { create(:conference, call_for_paper: create(:call_for_paper) ) }
  let!(:organizer_role) { create(:organizer_role, resource: conference) }
  let!(:organizer) { create(:user, email: 'admin@example.com', role_ids: [organizer_role.id]) }
  let!(:participant) { create(:user) }
  let!(:participant_without_bio) { create(:user, biography: '') }

  before(:each) do
    @options = {}
    @options[:send_mail] = 'false'
    @event = create(:event, conference: conference, title: 'Example Proposal')
  end

  after(:each) do
    sign_out
  end

  context 'as an conference organizer' do
    before(:each) do
      sign_in organizer
    end

    scenario 'rejects a proposal', feature: true, js: true do
      visit admin_conference_events_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true

      click_button 'New'
      click_link "reject_event_#{@event.id}"
      expect(flash).to eq('Event rejected!')
      @event.reload
      expect(@event.state).to eq('rejected')
    end

    scenario 'accepts a proposal', feature: true, js: true do
      visit admin_conference_events_path(conference.short_title)
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
      visit admin_conference_events_path(conference.short_title)
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
      @event.event_users = [create(:event_user,
                                   user_id: participant.id,
                                   event_id: @event.id,
                                   event_role: 'submitter')]
    end

    scenario 'submits a valid proposal', feature: true, js: true do
      sign_in participant_without_bio
      expected_count = Event.count + 1
      visit conference_proposal_index_path(conference.short_title)
      click_link 'New Proposal'

      fill_in 'event_title', with: 'Example Proposal'
      fill_in 'event_subtitle', with: 'Example Proposal Subtitle'

      select('Example Event Type', from: 'event[event_type_id]')

      fill_in 'event_abstract', with: 'Lorem ipsum abstract'
      fill_in 'event_description', with: 'Lorem ipsum description'

      fill_in 'user_biography', with: 'Lorem ipsum biography'

      click_button 'Create Event'
      expect(flash).to eq('Event was successfully submitted. You should register for the conference now.')

      expect(current_path).to eq(new_conference_conference_registrations_path(conference.short_title))
      expect(Event.count).to eq(expected_count)
    end

    scenario 'confirms a proposal', feature: true, js: true do
      sign_in participant
      visit conference_proposal_index_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true
      expect(page.has_content?('Unconfirmed')).to be true
      click_link "confirm_proposal_#{@event.id}"
      expect(flash).
          to eq('The proposal was confirmed. Please register to attend the conference.')
      @event.reload
      expect(@event.state).to eq('confirmed')
    end

    scenario 'withdraw a proposal', feature: true, js: true do
      sign_in participant
      @event.confirm!
      visit conference_proposal_index_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true
      expect(page.has_content?('Confirmed')).to be true
      click_link "delete_proposal_#{@event.id}"
      expect(flash).to eq('Proposal was successfully withdrawn.')
      @event.reload
      expect(@event.state).to eq('withdrawn')
    end
  end
end
