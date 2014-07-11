require 'spec_helper'

feature Room do
  # It is necessary to use bang version of let to build roles before user
  let!(:participant_role) { create(:participant_role) }
  let!(:organizer_role) { create(:organizer_role) }

  shared_examples 'rooms' do |user|
    scenario 'adds and updates rooms', feature: true, js: true do
      conference = create(:conference)
      sign_in create(user)
      visit admin_conference_rooms_path(
                conference_id: conference.short_title)

      # Add room
      click_link 'Add room'
      expect(page.all('div.nested-fields').count == 1).to be true

      page.
      find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) input').
          set('Example room')

      page.
      find('div.nested-fields:nth-of-type(1) div:nth-of-type(2) input').
          set('100')

      click_button 'Update Conference'

      # Validations
      expect(flash).to eq('Rooms were successfully updated.')
      expect(find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) input').
                 value).to eq('Example room')
      expect(find('div.nested-fields:nth-of-type(1) div:nth-of-type(2) input').
                 value).to eq('100')

      # Remove room
      click_link 'Remove room'
      expect(page.all('div.nested-fields').count == 0).to be true
      click_button 'Update Conference'
      expect(flash).to eq('Rooms were successfully updated.')
      expect(page.all('div.nested-fields').count == 0).to be true
    end
  end

  describe 'organizer' do
    it_behaves_like 'rooms', :organizer
  end
end
