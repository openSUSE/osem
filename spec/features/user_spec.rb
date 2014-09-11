require 'spec_helper'

feature User do
  shared_examples 'admin ability' do
    scenario 'deletes a user', feature: true, js: true do
      sign_in(create(:admin))
      @user = create(:user)
      visit admin_users_path
      expected_count = User.count - 1
      find("#user-delete-#{@user.id}").click
      page.evaluate_script('window.confirm = function() { return true; }')
      expect(flash).to eq('User got deleted')
      expect(User.count).to eq(expected_count)
      sign_out
    end
    scenario 'deletes a user with scheduled events', feature: true, js: true do
      sign_in(create(:admin))
      @user = create(:user)
      deleted_user = create(:deleted_user, email:'deleted@localhost.osem')
      @user.events << create(:event, start_time: DateTime.now)
      event = @user.events.first
      visit admin_users_path
      expected_count = User.count - 1
      find("#user-delete-#{@user.id}").click
      page.evaluate_script('window.confirm = function() { return true; }')
      expect(flash).to eq('User got deleted')
      expect(User.count).to eq(expected_count)
      expect(event.event_users.map{|x| User.find(x.user_id)}).to include(deleted_user)
      sign_out
    end
  end

  describe 'admin' do
    it_behaves_like 'admin ability', :admin
  end
end
