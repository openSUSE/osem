require 'spec_helper'

feature Campaign do

  # It is necessary to use bang version of let to build roles before user
  let!(:participant_role) { create(:participant_role) }
  let!(:organizer_conference_1_role) { create(:organizer_conference_1_role) }

  shared_examples 'add and update campaign' do |user|
    scenario 'adds and update a campaign', feature: true, js: true do
      expected_count = Campaign.count + 1
      conference = create(:conference, short_title: 'osc14')
      sign_in create(user)

      visit admin_conference_campaigns_path(conference.short_title)

      click_link 'New Campaign'

      click_button 'Create Campaign'

      expect(flash).
          to eq("Creating of Campaign for osc14 failed.Name can't be blank. Utm campaign can't be blank.")

      fill_in 'campaign_name', with: 'Test Campaign'
      fill_in 'campaign_utm_campaign', with: 'campaign'
      fill_in 'campaign_utm_source', with: 'source'
      fill_in 'campaign_utm_medium', with: 'medium'
      fill_in 'campaign_utm_term', with: 'term'
      fill_in 'campaign_utm_content', with: 'content'

      click_button 'Create Campaign'

      # Validations
      expect(flash).
          to eq('Campaign successfully created.')

      expect(find('#name_0').text).to eq('Test Campaign')
      expect(find('#visits_0').text).to eq('0')
      expect(find('#registrations_0').text).to eq('0')
      expect(find('#submissions_0').text).to eq('0')

      expect(Campaign.count).to eq(expected_count)

      campaign = Campaign.where('name' => 'Test Campaign').first
      visit edit_admin_conference_campaign_path(conference.short_title, campaign.id)

      fill_in 'campaign_name', with: 'Test Campaign 42'
      click_button 'Update Campaign'
      expect(flash).
          to eq("Campaign 'Test Campaign 42' successfully updated.")
    end
  end

  describe 'organizer' do
    it_behaves_like 'add and update campaign', :organizer_conference_1
  end
end
