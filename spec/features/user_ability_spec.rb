require 'spec_helper'

feature 'Has correct abilities' do

  let(:organization) { create(:organization) }
  let(:conference) { create(:full_conference, organization: organization) } # user is cfp
  let(:user) { create(:user) }

  context 'when user has no role' do
    before do
      sign_in user
    end

    scenario 'for administration views' do
      visit admin_conference_path(conference.short_title)

      expect(current_path).to eq conference_path(conference)
      expect(flash).to eq 'You are not authorized to access this page.'
    end
  end
end
