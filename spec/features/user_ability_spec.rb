# frozen_string_literal: true

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
      page.find('#flash')
      expect(current_path).to eq root_path
      expect(flash).to eq 'You are not authorized to access this page.'
    end
  end
end
