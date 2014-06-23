require 'spec_helper'

feature Event do
  # It is necessary to use bang version of let to build roles before user
  let!(:organizer_role) { create(:organizer_role) }
  let!(:participant_role) { create(:participant_role) }
  let!(:admin_role) { create(:admin_role) }

  shared_examples 'proposal workflow' do
    scenario 'submitts a proposal, accepts and confirms',
             feature: true, js: true do

      admin = create(:admin, email: 'admin@example.com')
      participant = create(:participant, email: 'participant@example.com')

      expected_count = Event.count + 1
      conference = create(:conference)
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

      select('YouTube', from: 'event[media_type]')
      fill_in 'event_media_id', with: '123456'

      fill_in 'user_biography', with: 'Lorem ipsum biography'
      fill_in 'user_name', with: 'Example User'

      click_button 'Submit Session'
      expect(current_path).to eq(register_conference_path(conference.short_title))

      expect(Event.count).to eq(expected_count)

      event = Event.where(title: 'Example Proposal').first

      visit conference_proposal_index_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true

      sign_out
      sign_in admin

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
          to eq('Event was confirmed. Please register to attend the conference.')

      # Register for conference
      find('#register').click
      expect(flash).to eq('You are now registered.')

      # Withdraw proposal
      visit conference_proposal_index_path(conference.short_title)
      expect(page.has_content?('Confirmed')).to be true
      click_link "delete_proposal_#{event.id}"
      expect(flash).to eq('Proposal withdrawn.')
    end
  end

  describe 'proposal' do
    it_behaves_like 'proposal workflow'
  end
end
