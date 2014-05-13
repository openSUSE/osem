require 'spec_helper'

feature Event do

  shared_examples 'proposal workflow' do
    scenario 'submitts a new proposal, accepts and confirms', feature: true, js: true do
      admin = create(:admin, email: 'admin@example.com')
      participant = create(:participant, email: 'participant@example.com')

      expected_count = Event.count + 1
      conference = create(:conference)
      conference.call_for_papers = create(:call_for_papers)
      conference.email_settings = create(:email_settings)
      conference.event_types = [create(:event_type)]

      #Submit a new proposal as participant
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

      fill_in 'person_biography', with: 'Lorem ipsum biography'
      fill_in 'person_public_name', with: 'Example User'

      click_button 'Submit Session'
      expect(current_path).to eq(edit_user_registration_path)

      fill_in 'user_person_attributes_first_name', with: 'Example'
      fill_in 'user_person_attributes_last_name', with: 'User'
      fill_in 'user_person_attributes_biography', with: 'Lorem ipsum biography'

      click_button 'Update'

      expect(page.find('#flash_notice').text).
          to eq('You updated your account successfully.')

      expect(Event.count).to eq(expected_count)

      visit conference_proposal_index_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true

      sign_out

      #Accept proposal as admin
      sign_in admin

      visit admin_conference_events_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true

      click_link 'New'
      click_link 'accept_event'

      expect(page.has_content?('Unconfirmed')).to be true
      sign_out

      #Confirm proposal as participant
      sign_in participant
      visit conference_proposal_index_path(conference.short_title)
      expect(page.has_content?('Example Proposal')).to be true
      expect(page.has_content?('Accepted (confirmation pending)')).to be true
      click_link 'confirm_proposal'
      expect(page.find('#flash_notice').text).
          to eq('Event was confirmed. Please register to attend the conference.')

      find('#register').click

      expect(page.find('#flash_notice').text).
          to eq('You are now registered.')
    end
  end

  describe 'proposal' do
    it_behaves_like 'proposal workflow'
  end
end
