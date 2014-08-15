require 'spec_helper'

feature User do

  shared_examples 'admin ability' do
    scenario 'deletes a user', feature: true, js: true do
      sign_in(create(:admin))
      visit admin_users_path
      expected_count = User.count - 1
      page.all('btn btn-primary btn-danger') do
        click_link 'Delete'
        page.evaluate_script('window.confirm = function() { return true; }')
        page.click('OK')
        expect(flash).to eq('User got deleted')
        expect(User.count).to eq(expected_count)
      end
      sign_out
    end
  end

  describe 'admin' do
    it_behaves_like 'admin ability', :admin
  end
end
