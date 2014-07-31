require 'spec_helper'

feature Photo do

  # It is necessary to use bang version of let to build roles before user
  let!(:organizer_role) { create(:organizer_role) }
  let!(:participant_role) { create(:participant_role) }
  let!(:admin_role) { create(:admin_role) }

  shared_examples 'add and update photo' do |user|
    scenario 'adds a new photo', feature: true, js: true do
      expected_count = Photo.count + 1
      conference = create(:conference)
      sign_in create(user)

      visit new_admin_conference_photo_path(conference.short_title)

      file_path = Rails.root + 'spec/fixtures/suse.jpg'
      attach_file('photo_picture', file_path)
      fill_in 'photo_description', with: 'Lorem ipsum dolorem...'

      click_button 'Save Photo'

      expect(flash).
          to eq('Photo was successfully created.')
      expect(Photo.count).to eq(expected_count)
    end

    scenario 'updates a photo', feature: true, js: true do
      expected_count = Photo.count + 1
      conference = create(:conference)
      photo = create(:photo)
      sign_in create(user)

      visit edit_admin_conference_photo_path(conference.short_title, photo.id)

      file_path = Rails.root + 'spec/fixtures/suse_pinguin.png'
      attach_file('photo_picture', file_path)
      fill_in 'photo_description', with: 'Lorem ipsum dolorem...'

      click_button 'Save Photo'

      expect(flash).
          to eq('Photo was successfully updated.')
      expect(Photo.count).to eq(expected_count)
    end

    scenario 'adds a text file', feature: true, js: true do
      expected_count = Photo.count
      conference = create(:conference)
      sign_in create(user)

      visit new_admin_conference_photo_path(conference.short_title)

      file_path = Rails.root + 'spec/fixtures/test.txt'
      attach_file('photo_picture', file_path)
      fill_in 'photo_description', with: 'Lorem ipsum dolorem...'

      click_button 'Save Photo'

      expect(flash).
          to eq("A error prohibited this Photo from being saved: Picture has an extension that does not match its contents. "\
          "Picture is invalid. Picture content type is invalid.")
      expect(Photo.count).to eq(expected_count)
    end
  end

  describe 'admin' do
    it_behaves_like 'add and update photo', :admin
  end

  describe 'organizer' do
    it_behaves_like 'add and update photo', :organizer
  end

end
