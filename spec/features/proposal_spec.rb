require 'spec_helper'

feature Event do
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { create(:organizer_role, resource: conference) }
  let!(:organizer) { create(:user, email: 'admin@example.com', role_ids: [organizer_role.id]) }
  let!(:participant) { create(:user, biography: '') }

  shared_examples 'proposal workflow' do
    scenario 'submitts a proposal, accepts and confirms',
             feature: true, js: true do

      expected_count = Event.count + 1

      conference.call_for_papers = create(:call_for_papers)
      conference.email_settings = create(:email_settings)
      conference.event_types = [create(:event_type)]

      # Submit a new proposal as participant
      sign_in participant

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

      event = Event.where(title: 'Example Proposal').first

      visit conference_proposal_index_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true

      expected_count_commercial = Commercial.count + 1
      # Add a invalid commercial
      visit edit_conference_proposal_path(conference.short_title, event.id)

      click_link 'Commercials'
      click_link 'Add Commercial'

      select('SlideShare', from: 'commercial_commercial_type')

      click_button 'Create Commercial'
      expect(flash).to eq("A error prohibited this Commercial from being saved: Commercial can't be blank.")
      expect(event.commercials.count).to eq(expected_count_commercial - 1)

      # Add a valid commercial
      visit edit_conference_proposal_path(conference.short_title, event.id)

      click_link 'Commercials'
      click_link 'Add Commercial'

      select('SlideShare', from: 'commercial_commercial_type')
      fill_in 'commercial_commercial_id', with: '12345'

      click_button 'Create Commercial'
      expect(flash).to eq('Commercial was successfully created.')
      expect(event.commercials.count).to eq(expected_count_commercial)

      # Edit an invalid commercial
      click_link 'Commercials'
      click_link 'Edit'

      select('SlideShare', from: 'commercial_commercial_type')
      fill_in 'commercial_commercial_id', with: ''

      click_button 'Update Commercial'
      expect(flash).to eq("A error prohibited this Commercial from being saved: Commercial can't be blank.")
      expect(event.commercials.count).to eq(expected_count_commercial)

      # Edit a valid commercial
      select('SlideShare', from: 'commercial_commercial_type')
      fill_in 'commercial_commercial_id', with: '56789'

      click_button 'Update Commercial'
      expect(flash).to eq('Commercial was successfully updated.')
      expect(event.commercials.count).to eq(expected_count_commercial)

      # Delete a commercial
      click_link 'Commercials'
      click_link 'Delete'
      page.driver.network_traffic
      expect(flash).to eq('Commercial was successfully destroyed.')
      expect(event.commercials.count).to eq(expected_count_commercial - 1)

      sign_out
      sign_in organizer

      # Reject proposal
      visit admin_conference_events_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true

      click_button 'New'
      click_link "reject_event_#{event.id}"
      expect(flash).to eq('Event rejected!')
      click_button 'Rejected'
      click_link "restart_event_#{event.id}"
      expect(flash).to eq('Review started!')

      # Start review
      click_button 'New'
      click_link "accept_event_#{event.id}"
      expect(flash).to eq('Event accepted!')
      expect(page.has_content?('Unconfirmed')).to be true
      sign_out

      # Confirm proposal as participant
      sign_in participant
      visit conference_proposal_index_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true
      expect(page.has_content?('Unconfirmed')).to be true
      click_link "confirm_proposal_#{event.id}"
      expect(flash).
          to eq('The proposal was confirmed. Please register to attend the conference.')

      # Register for conference
      find('#register').click
      expect(flash).to eq('You are now registered and will be receiving E-Mail notifications.')

      # Withdraw proposal
      visit conference_proposal_index_path(conference.short_title)
      expect(page.has_content?('Confirmed')).to be true
      click_link "delete_proposal_#{event.id}"
      expect(flash).to eq('Proposal was successfully withdrawn.')
    end
  end

  describe 'proposal' do
    it_behaves_like 'proposal workflow'
  end
end
