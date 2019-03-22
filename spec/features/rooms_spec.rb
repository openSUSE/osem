# frozen_string_literal: true

require 'spec_helper'

feature Room do
  let!(:conference) { create(:conference) }
  let!(:venue) { create(:venue, conference: conference) }
  let!(:organizer) { create(:organizer, resource: conference) }

  shared_examples 'rooms' do
    scenario 'adds a room', feature: true, js: true do
      sign_in organizer
      visit admin_conference_venue_rooms_path(
                conference_id: conference.short_title)

      expect(page.has_no_table?('#rooms')).to be true

      # Add room
      click_link 'Add Room'

      fill_in 'room_name', with: 'Auditorium'
      fill_in 'room_size', with: '100'

      click_button 'Create Room'
      page.find('#flash')
      # Validations
      expect(flash).to eq('Room successfully created.')
      within('table#rooms') do
        expect(page.has_content?('Auditorium')).to be true
        expect(page.assert_selector('tr', count: 2)).to be true
      end
    end

    scenario 'updates a room', feature: true, js: true do
      room = create(:room, venue: venue)
      sign_in organizer
      visit edit_admin_conference_venue_room_path(
                conference_id: conference.short_title, id: room.id)

      fill_in 'room_name', with: 'Auditorium'
      fill_in 'room_size', with: '100'

      click_button 'Update Room'
      page.find('#flash')
      # Validations
      expect(flash).to eq('Room successfully updated.')
      within('table#rooms') do
        expect(page.has_content?('Auditorium')).to be true
        expect(page.assert_selector('tr', count: 2)).to be true
      end
      room.reload
      expect(room.name).to eq('Auditorium')
      expect(room.size).to eq(100)
    end
  end

  describe 'organizer' do
    it_behaves_like 'rooms'
  end
end
