require 'spec_helper'

feature Event do

  shared_examples 'proposal' do |user|
    scenario 'submitts a new proposal and updates account', feature: true, js: true do
      expected_count = Event.count + 1
      conference = create(:conference)
      conference.call_for_papers = create(:call_for_papers)
      conference.event_types = [create(:event_type)]

      sign_in create(user)

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

      click_button 'Update'

      expect(page.find('#flash_notice').text).
          to eq('You updated your account successfully.')

      expect(Event.count).to eq(expected_count)
    end
  end

  describe 'proposal workflow' do
    it_behaves_like 'proposal', :participant
    it_behaves_like 'proposal', :organizer
    it_behaves_like 'proposal', :admin
  end
end
