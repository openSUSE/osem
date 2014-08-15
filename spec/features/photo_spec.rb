require 'spec_helper'

feature Photo do

  let!(:conference) { create(:conference) }
  let!(:organizer_role) { create(:organizer_role, resource: conference) }
  let!(:organizer) { create(:user, email: 'admin@example.com', role_ids: [organizer_role.id]) }

  shared_examples 'add and update photo' do
    scenario 'adds a new photo', feature: true, js: true do
      expected_count = Photo.count + 1

      sign_in organizer

      visit new_admin_conference_photo_path(conference.short_title)

      file_path = Rails.root.join('app', 'assets', 'images', 'rails.png')
      attach_file('photo_picture', file_path)
      fill_in 'photo_description', with: 'Lorem ipsum dolorem...'

      click_button 'Save Photo'

      expect(flash).
          to eq('Photo was successfully created.')
      expect(Photo.count).to eq(expected_count)
    end

    scenario 'updates a photo', feature: true, js: true do
      expected_count = Photo.count + 1
      photo = create(:photo, conference_id: conference.id)
      sign_in organizer

      visit edit_admin_conference_photo_path(conference.short_title, photo.id)

      file_path = Rails.root.join('app', 'assets', 'images', 'person_large.png')
      attach_file('photo_picture', file_path)
      fill_in 'photo_description', with: 'Lorem ipsum dolorem...'

      click_button 'Save Photo'

      expect(flash).
          to eq('Photo was successfully updated.')
      expect(Photo.count).to eq(expected_count)
    end

    scenario 'adds a text file', feature: true, js: true do
      expected_count = Photo.count
      sign_in organizer

      visit new_admin_conference_photo_path(conference.short_title)

      file_path = Rails.root + 'spec/fixtures/test.txt'
      attach_file('photo_picture', file_path)
      fill_in 'photo_description', with: 'Lorem ipsum dolorem...'

      click_button 'Save Photo'

      expect(flash).
          to eq("A error prohibited this Photo from being saved: Picture content type is invalid. Picture is invalid.")
      expect(Photo.count).to eq(expected_count)
    end
  end

  describe 'organizer' do
    it_behaves_like 'add and update photo'
  end

end
