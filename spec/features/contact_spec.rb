require 'spec_helper'

feature Contact do

  let!(:conference) { create(:conference) }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, email: 'admin@example.com', role_ids: [organizer_role.id]) }

  shared_examples 'update a contact' do

    scenario 'sucessfully', feature: true, js: true do
      contact = conference.contact
      expected_count = Contact.count
      sign_in organizer

      visit edit_admin_conference_contact_path(conference.short_title)

      fill_in 'contact_email', with: 'example@example.com'
      fill_in 'contact_sponsor_email', with: 'sponsor@example.com'
      fill_in 'contact_social_tag', with: 'example'
      fill_in 'contact_facebook', with: 'http:\\www.facebook.com'
      fill_in 'contact_twitter', with: 'http:\\www.twitter.com'
      fill_in 'contact_instagram', with: 'http:\\www.instagram.com'
      fill_in 'contact_googleplus', with: 'http:\\www.google.com'

      click_button 'Update Contact'

      expect(flash)
          .to eq('Contact details were successfully updated.')
      contact.reload
      expect(contact.email).to eq('example@example.com')
      expect(contact.sponsor_email).to eq('sponsor@example.com')
      expect(contact.social_tag).to eq('example')
      expect(contact.facebook).to eq('http:\\www.facebook.com')
      expect(contact.twitter).to eq('http:\\www.twitter.com')
      expect(contact.instagram).to eq('http:\\www.instagram.com')
      expect(contact.googleplus).to eq('http:\\www.google.com')
      expect(Contact.count).to eq(expected_count)
    end
  end

  describe 'organizer' do
    it_behaves_like 'update a contact', :organizer
  end

end
