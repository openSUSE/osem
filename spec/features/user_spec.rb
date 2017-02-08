require 'spec_helper'

feature User do
  let!(:user) {create(:user, :with_social_media_and_code_info)}

  describe 'update user profile' do
    scenario 'sucessfully', feature: true do
      sign_in user
      visit edit_user_path(user.id)
      fill_in 'user_website_url', with: 'http://www.example1.com'
      fill_in 'user_linkedin', with: 'http://www.linkedin.com/testosemuser1'
      fill_in 'user_gnu', with: 'http://gnu.io/testosemuser1'
      fill_in 'user_twitter', with: 'http://www.twitter.com/testosemuser1'
      fill_in 'user_github', with: 'http://www.github.com/testosemuser1'
      fill_in 'user_gitlab', with: 'http://www.gitlab.com/testosemuser1'
      fill_in 'user_gna', with: 'http://www.gna.com/testosemuser1'
      fill_in 'user_diaspora', with: 'http://joindiaspora.com/testosemuser1'
      fill_in 'user_savannah', with: 'http://savannah.gnu.org/testosemuser1'
      fill_in 'user_googleplus', with: 'http://plus.google.com/testosemurl1'

      click_button 'Update'

      expect(flash). to eq('User was successfully updated.')
      user.reload
      expect(user.website_url).to eq('http://www.example1.com')
      expect(user.linkedin).to eq('http://www.linkedin.com/testosemuser1')
      expect(user.gnu).to eq('http://gnu.io/testosemuser1')
      expect(user.twitter).to eq('http://www.twitter.com/testosemuser1')
      expect(user.github).to eq('http://www.github.com/testosemuser1')
      expect(user.gitlab).to eq('http://www.gitlab.com/testosemuser1')
      expect(user.googleplus).to eq('http://plus.google.com/testosemurl1')
      expect(user.gna).to eq('http://www.gna.com/testosemuser1')
      expect(user.diaspora).to eq('http://joindiaspora.com/testosemuser1')
      expect(user.savannah).to eq('http://savannah.gnu.org/testosemuser1')
    end
  end

  shared_examples 'admin ability' do

  end

  describe 'admin' do
    it_behaves_like 'admin ability', :admin
  end

end
