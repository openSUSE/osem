require 'spec_helper'

feature Contact do

  # It is necessary to use bang version of let to build roles before user
  let!(:organizer_role) { create(:organizer_role) }
  let!(:participant_role) { create(:participant_role) }
  let!(:admin_role) { create(:admin_role) }

  shared_examples 'update a contact' do |user|

    scenario 'sucessfully', feature: true, js: true do
      conference = create(:conference)
      contact = conference.contact
      expected_count = Contact.count
      sign_in create(user)

      visit edit_admin_conference_contact_path(conference.short_title)
      click_link 'Edit'
      fill_in 'contact_email', with: 'example@example.com'
      fill_in 'contact_social_tag', with: 'example'
      fill_in 'contact_facebook', with: 'http:\\www.facebook.com'
      fill_in 'contact_twitter', with: 'http:\\www.twitter.com'
      fill_in 'contact_instagram', with: 'http:\\www.instagram.com'
      fill_in 'contact_googleplus', with: 'http:\\www.google.com'

      click_button 'Update Contact'
      expect(flash).
          to eq('Contact details were successfully updated.')

      contact.reload
      expect(contact.email).to eq('example@example.com')
      expect(contact.social_tag).to eq('example')
      expect(contact.facebook).to eq('http:\\www.facebook.com')
      expect(contact.twitter).to eq('http:\\www.twitter.com')
      expect(contact.instagram).to eq('http:\\www.instagram.com')
      expect(contact.googleplus).to eq('http:\\www.google.com')
      expect(Contact.count).to eq(expected_count)
    end
  end

  describe 'admin' do
    it_behaves_like 'update a contact', :admin
  end

  describe 'organizer' do
    it_behaves_like 'update a contact', :organizer
  end

end
