require 'spec_helper'

feature User do

  let(:admin) { create(:admin) }

  shared_examples 'admin ability' do
    scenario 'manually confirm unconfirmed users', feature: true, js: true do
      sign_in admin
      user = create(:user, confirmed_at: nil)
      expect(user.confirmed?).to be false
      visit admin_users_path

      within('tr', text: user.name) do
        expect(page.has_content?('unconfirmed')).to be true
        click_link 'Confirm'
      end

      user.reload
      expect(user.confirmed?).to be true
    end
  end

  describe 'admin' do
    it_behaves_like 'admin ability', :admin
  end
end
