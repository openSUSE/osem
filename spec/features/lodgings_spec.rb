require 'spec_helper'

feature Lodging do
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { create(:organizer_role, resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

  shared_examples 'lodgings' do
    scenario 'adds and updates lodgings', feature: true, js: true do
      path = "#{Rails.root}/app/assets/images/rails.png"

      conference.venue = create(:venue)
      sign_in organizer
      visit admin_conference_lodgings_path(
                conference_id: conference.short_title)
      # Add lodging
      click_link 'Add lodging'
      expect(page.all('div.nested-fields').count == 1).to be true
      page.
      find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) input').
          set('Example Hotel')

      page.
      find('div.nested-fields:nth-of-type(1) div:nth-of-type(2) textarea').
          set('Lorem Ipsum Dolor')

      attach_file 'Photo', path

      page.
      find('div.nested-fields:nth-of-type(1) div:nth-of-type(4) input').
          set('http://www.example.com')

      click_button 'Update Venue'

      # Validations
      expect(flash).to eq('Lodgings were successfully updated.')

      expect(find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) input').
                 value).to eq('Example Hotel')

      expect(find('div.nested-fields:nth-of-type(1) div:nth-of-type(2) textarea').
                 value).to eq('Lorem Ipsum Dolor')

      expect(page).to have_selector("img[src*='rails.png']")

      expect(find('div.nested-fields:nth-of-type(1) div:nth-of-type(4) input').
                 value).to eq('http://www.example.com')

      # Remove room
      click_link 'Remove lodging'
      expect(page.all('div.nested-fields').count == 0).to be true
      click_button 'Update Venue'
      expect(flash).to eq('Lodgings were successfully updated.')
      expect(page.all('div.nested-fields').count == 0).to be true
    end
  end

  describe 'organizer' do
    it_behaves_like 'lodgings'
  end
end
