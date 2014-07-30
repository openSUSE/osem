require 'spec_helper'
feature User do
  # It is necessary to use bang version of let to build roles before user
  let!(:participant_role) { create(:participant_role) }
  let!(:organizer_role) { create(:organizer_role) }
  let(:organizer) { create(:organizer) }

  shared_examples 'organizer ability' do |_user|
    scenario 'deletes a user', feature: true, js: true do
      sign_in(organizer)
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
    scenario 'can modify roles', feature: true, js: true do
      @user = create(:user)
      sign_in(organizer)
      visit admin_users_path
      find("#user-modify-role-#{@user.id}").click
      if find("#user-role-selection-#{@user.id}").visible?
        page.find('#user_role_ids').find(:xpath, 'option[2]').select_option do
          find('#user_submit_action').click
          expect(flash).to eq("Updated #{@user.email}")
          expect(@user.role_ids).to match_array([2])
        end
      end
      sign_out
    end
  end

  describe 'organizer' do
    it_behaves_like 'organizer ability', :organizer
  end
end
