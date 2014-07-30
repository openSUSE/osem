require 'spec_helper'

feature Conference do

  # It is necessary to use bang version of let to build roles before user
  let!(:organizer_role) { create(:organizer_role) }
  let!(:participant_role) { create(:participant_role) }
  let!(:admin_role) { create(:admin_role) }

  shared_examples 'add and update conference' do |user|
    scenario 'adds a new conference', feature: true, js: true do
      expected_count = Conference.count + 1
      sign_in create(user)

      visit new_admin_conference_path
      fill_in 'conference_title', with: 'Example Con'
      fill_in 'conference_short_title', with: 'ExCon'
      fill_in 'conference_social_tag', with: 'ExCon'

      select('(GMT+01:00) Berlin', from: 'conference[timezone]')

      page.
      execute_script("$('#conference-start-datepicker').val('" +
                         "#{1.weeks.from_now.strftime('%d/%m/%Y')}')")
      page.
      execute_script("$('#conference-end-datepicker').val('" +
                         "#{2.weeks.from_now.strftime('%d/%m/%Y')}')")

      click_button 'Create Conference'

      expect(flash).
          to eq('Conference was successfully created.')
      expect(Conference.count).to eq(expected_count)
    end

    scenario 'update basic conference settings', feature: true, js: true do
      conference = create(:conference)
      expected_count = Conference.count
      sign_in create(user)

      visit edit_admin_conference_conference_basics_path(conference.short_title)
      click_link 'Edit'
      fill_in 'conference_title', with: 'New Con'
      fill_in 'conference_short_title', with: 'NewCon'

      fill_in 'conference_description', with: 'Lorem ipsum dolorem...'
      select('YouTube', from: 'conference_media_type')
      fill_in 'conference_media_id', with: '123456'

      page.
          execute_script("$('#conference-start-datepicker').val('" +
                             "#{2.weeks.from_now.strftime('%d/%m/%Y')}')")
      page.
          execute_script("$('#conference-end-datepicker').val('" +
                             "#{3.weeks.from_now.strftime('%d/%m/%Y')}')")

      click_button 'Update Conference'
      expect(flash).
          to eq('Conference was successfully updated.')

      conference.reload
      expect(conference.title).to eq('New Con')
      expect(conference.description).to eq('Lorem ipsum dolorem...')
      expect(conference.media_type).to eq('YouTube')
      expect(conference.media_id).to eq('123456')
      expect(conference.start_date).to eq(2.weeks.from_now.to_date)
      expect(conference.end_date).to eq(3.weeks.from_now.to_date)
      expect(conference.short_title).to eq('NewCon')

      expect(Conference.count).to eq(expected_count)
    end

    scenario 'update contact conference settings', feature: true, js: true do
      conference = create(:conference)
      expected_count = Conference.count
      sign_in create(user)

      visit edit_admin_conference_conference_contacts_path(conference.short_title)
      click_link 'Edit'

      fill_in 'conference_contact_email', with: 'example@example.de'
      fill_in 'conference_social_tag', with: '#social-tag'
      fill_in 'conference_facebook_url', with: 'http://www.facebook.com'
      fill_in 'conference_google_url', with: 'http://www.google.com'
      fill_in 'conference_twitter_url', with: 'http://www.twitter.com'
      fill_in 'conference_instagram_url', with: 'http://www.instagram.com'

      click_button 'Update Conference'
      expect(flash).
          to eq('Conference was successfully updated.')

      conference.reload
      expect(conference.contact_email).to eq('example@example.de')
      expect(conference.social_tag).to eq('#social-tag')
      expect(conference.facebook_url).to eq('http://www.facebook.com')
      expect(conference.google_url).to eq('http://www.google.com')
      expect(conference.twitter_url).to eq('http://www.twitter.com')
      expect(conference.instagram_url).to eq('http://www.instagram.com')

      expect(Conference.count).to eq(expected_count)
    end
  end

  describe 'admin' do
    it_behaves_like 'add and update conference', :admin
  end

  describe 'organizer' do
    it_behaves_like 'add and update conference', :organizer
  end

end
