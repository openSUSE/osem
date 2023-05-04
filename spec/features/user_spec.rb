# frozen_string_literal: true

require 'spec_helper'

feature User do
  let(:admin) { create(:admin) }
  let!(:user) { create(:user) }

  shared_examples 'admin ability' do
    scenario 'edits a user', feature: true, js: true do
      visit admin_users_path
      within "tr#user_#{user.id}" do
        click_on 'Edit'
      end
      fill_in 'Name', with: 'Edited Name'
      click_button 'Update User'
      expect(flash).to include('Updated Edited Name')
    end
  end

  describe 'admin' do
    before { sign_in admin }

    it_behaves_like 'admin ability', :admin
  end
end
