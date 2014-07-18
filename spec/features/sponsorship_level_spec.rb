require 'spec_helper'

feature SponsorshipLevel do
  # It is necessary to use bang version of let to build roles before user
  let!(:participant_role) { create(:participant_role) }
  let!(:organizer_conference_1_role) { create(:organizer_conference_1_role) }

  shared_examples 'sponsorship levels' do |user|
    scenario 'adds and updates sponsorship level', feature: true, js: true do
      conference = create(:conference)
      sign_in create(user)
      visit admin_conference_sponsorship_levels_path(
                conference_id: conference.short_title)
      # Add sponsorship level
      click_link 'Add sponsorship_level'
      expect(page.all('div.nested-fields').count == 1).to be true

      page.
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) input').
          set('Example sponsorship level')

      click_button 'Update Conference'

      # Validations
      expect(flash).to eq('Sponsorship levels were successfully updated.')
      expect(find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) input').
                 value).to eq('Example sponsorship level')

      # Remove sponsorship level
      click_link 'Remove sponsorship_level'
      expect(page.all('div.nested-fields').count == 0).to be true
      click_button 'Update Conference'
      expect(flash).to eq('Sponsorship levels were successfully updated.')
      expect(page.all('div.nested-fields').count == 0).to be true
    end
  end

  describe 'organizer' do
    it_behaves_like 'sponsorship levels', :organizer_conference_1
  end
end
