require 'spec_helper'

feature Campaign do

  let!(:conference) { create(:conference, short_title: 'osc14') }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

  shared_examples 'add and update campaign' do
    scenario 'adds and update a campaign', feature: true, js: true do
      expected_count = Campaign.count + 1
      sign_in organizer

      visit admin_conference_campaigns_path(conference.short_title)

      click_link 'New Campaign'

      click_button 'Create Campaign'

      expect(flash).to eq("Campaign creation failed. Name can't be blank and Utm campaign can't be blank")

      fill_in 'campaign_name', with: 'Test Campaign'
      fill_in 'campaign_utm_campaign', with: 'campaign'
      fill_in 'campaign_utm_source', with: 'source'
      fill_in 'campaign_utm_medium', with: 'medium'
      fill_in 'campaign_utm_term', with: 'term'
      fill_in 'campaign_utm_content', with: 'content'

      click_button 'Create Campaign'

      # Validations
      expect(flash).to eq('Campaign successfully created.')

      expect(page).to have_selector('[id^="name_"]', text: 'Test Campaign')
      expect(page).to have_selector('[id^="visits_"]', text: '0')
      expect(page).to have_selector('[id^="registrations_"]', text: '0')
      expect(page).to have_selector('[id^="submissions_"]', text: '0')

      expect(Campaign.count).to eq(expected_count)

      campaign = Campaign.where('name' => 'Test Campaign').first
      visit edit_admin_conference_campaign_path(conference.short_title, campaign.id)

      fill_in 'campaign_name', with: 'Test Campaign 42'
      click_button 'Update Campaign'
      expect(flash).to eq("Campaign 'Test Campaign 42' successfully updated.")
    end
  end

  describe 'organizer' do
    it_behaves_like 'add and update campaign'
  end
end
