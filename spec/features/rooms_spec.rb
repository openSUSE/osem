require 'spec_helper'

feature Room do
  # It is necessary to use bang version of let to build roles before user
  let!(:organizer_role) { create(:organizer_role) }
  let!(:participant_role) { create(:participant_role) }
  let!(:admin_role) { create(:admin_role) }

  shared_examples 'rooms' do |user|
    scenario 'adds and updates rooms', feature: true, js: true do
      conference = create(:conference)
      expected_count = Room.count + 1
      sign_in create(user)
      visit admin_conference_rooms_path(
                conference_id: conference.short_title)

      # Add room
      click_link 'New Room'
      fill_in 'room_name', with: 'Room1000'
      fill_in 'room_size', with: '500'
      check('room_public')
      click_button 'Save Room'

      # Validations
      expect(Room.count).to eq(expected_count)
      expect(flash).to eq('Room was successfully created.')
      expect(page.has_content?('Room1000')).to be true
      expect(page.has_content?('500')).to be true

      # Update room
      click_link 'Room1000'
      fill_in 'room_name', with: 'Room2000'
      fill_in 'room_size', with: '600'
      check('room_public')
      click_button 'Save Room'

      # Validations
      expect(Room.count).to eq(expected_count)
      expect(flash).to eq('Room was successfully updated.')
      expect(page.has_content?('Room2000')).to be true
      expect(page.has_content?('600')).to be true

      # Remove room
      click_link 'Delete'

      # Validations
      expect(Room.count).to eq(expected_count - 1)
      expect(flash).to eq('Room was successfully destroyed.')
      expect(page.has_content?('Room2000')).to be false
      expect(page.has_content?('600')).to be false
    end
  end

  describe 'admin' do
    it_behaves_like 'rooms', :admin
  end

  describe 'organizer' do
    it_behaves_like 'rooms', :organizer
  end
end
