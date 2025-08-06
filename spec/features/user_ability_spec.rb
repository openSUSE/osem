# frozen_string_literal: true

require 'spec_helper'

feature 'Has correct abilities' do

  let(:conference) { create(:full_conference) } # user is cfp
  let(:user) { create(:user) }

  context 'when user has no role' do
    before do
      sign_in user
    end

    scenario 'for administration views' do
      visit admin_conference_path(conference.short_title)

      expect(current_path).to eq root_path
      within('#flash') { expect(page).to have_text('You are not authorized to access this page.') }
    end
  end
end
