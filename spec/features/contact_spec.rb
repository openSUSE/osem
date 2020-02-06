# frozen_string_literal: true

require 'spec_helper'

feature Contact do

  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }

  shared_examples 'contact field' do |field_name, field_value|
    it 'updates a contact' do
      contact = conference.contact
      expected_count = Contact.count

      visit edit_admin_conference_contact_path(conference.short_title)
      fill_in 'contact_' + field_name, with: field_value
      click_button 'Update Contact'
      page.find('#flash')
      expect(flash)
          .to eq('Contact details were successfully updated.')
      contact.reload

      expect(contact.send(field_name)).to eq(field_value)
      expect(Contact.count).to eq(expected_count)
    end
  end

  describe 'organizer' do
    before do
      sign_in organizer
    end

    context 'editing', feature: true do
      it_behaves_like 'contact field', 'email', 'example@example.com'
      it_behaves_like 'contact field', 'sponsor_email', 'sponsor@example.com'
      it_behaves_like 'contact field', 'social_tag', 'example'
      it_behaves_like 'contact field', 'facebook', 'http://www.facebook.com'
      it_behaves_like 'contact field', 'twitter', 'http://www.twitter.com'
      it_behaves_like 'contact field', 'instagram', 'http://www.instagram.com'
      it_behaves_like 'contact field', 'googleplus', 'http://www.google.com'
      it_behaves_like 'contact field', 'blog', 'http://blog.localdomain'
      it_behaves_like 'contact field', 'youtube', 'https://youtube.com/osem'
    end
  end
end
