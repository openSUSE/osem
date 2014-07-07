require 'spec_helper'

feature Sponsor do
  # It is necessary to use bang version of let to build roles before user
  let!(:organizer_role) { create(:organizer_role) }
  let!(:participant_role) { create(:participant_role) }
  let!(:admin_role) { create(:admin_role) }

  shared_examples 'sponsors' do |user|
    scenario 'adds and updates sponsors', feature: true, js: true do
      path = "#{Rails.root}/app/assets/images/rails.png"
      conference = create(:conference)
      conference.sponsorship_levels << create(:sponsorship_level, conference: conference)
      sign_in create(user)

      visit admin_conference_sponsors_path(
                conference_id: conference.short_title)
      # Add sponsors
      click_link 'Add sponsor'

      expect(page.all('div.nested-fields').count == 1).to be true

      page.
      find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) input').
          set('Example sponsor')

      page.
      find('div.nested-fields:nth-of-type(1) div:nth-of-type(2) textarea').
          set('Lorem Ipsum')

      attach_file 'Logo', path

      page.
      find('div.nested-fields:nth-of-type(1) div:nth-of-type(4) input').
          set('http://www.example.com')

      find(:css, "select[id^='conference_sponsors_attributes_']"\
                 "[id$='_sponsorship_level_id']").
                      find(:option, 'Platin').select_option

      click_button 'Update Conference'

      expect(flash).to eq('Sponsorships were successfully updated.')

      expect(find('div.nested-fields:nth-of-type(1)'\
                  ' div:nth-of-type(1) input').
                      value).to eq('Example sponsor')

      expect(find('div.nested-fields:nth-of-type(1)'\
                  ' div:nth-of-type(2) textarea').
                      value).to eq('Lorem Ipsum')

      expect(page).to have_selector("img[src*='rails.png']")

      expect(find('div.nested-fields:nth-of-type(1)'\
                  ' div:nth-of-type(4) input').
                      value).to eq('http://www.example.com')

      expect(find('div.nested-fields:nth-of-type(1)'\
                  ' div:nth-of-type(5) select:nth-of-type(1)').find('option[selected]').
                      text).to eq('Platin')

      # Remove sponsor
      click_link 'Remove sponsor'
      expect(page.all('div.nested-fields').count == 0).to be true
      click_button 'Update Conference'
      expect(flash).to eq('Sponsorships were successfully updated.')
      expect(page.all('div.nested-fields').count == 0).to be true
    end
  end

  describe 'admin' do
    it_behaves_like 'sponsors', :admin
  end

  describe 'organizer' do
    it_behaves_like 'sponsors', :organizer
  end
end
