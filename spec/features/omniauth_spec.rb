require 'spec_helper'

feature Openid do
  let!(:participant_role) { create(:participant_role) }
  let!(:admin_role) { create(:admin_role) }

  describe 'sign in with openid' do

    it 'has option to log in with Google account' do
      visit '/accounts/sign_in'
      expect(page.has_content?('Or use your openID')).to be true
      expect(page.has_content?('google')).to be true
    end

    it 'signs in *new* user with Google account' do
      expected_count_openid = Openid.count + 1
      expected_count_user = User.count + 1
      visit '/accounts/sign_in'

      mock_auth_new_user
      click_link 'google'
      expect(flash).to eq('test-1@gmail.com signed in successfully with google')
      expect(Openid.count).to eq(expected_count_openid)
      expect(User.count).to eq(expected_count_user)
    end

    it 'signs in an existing user' do
      create(:participant, email: 'test-participant-1@google.com')
      expected_count_openid = Openid.count + 1
      expected_count_user = User.count
      visit '/accounts/sign_in'

      mock_auth_existing_user_participant
      click_link 'google'
      expect(flash).to eq('test-participant-1@google.com signed in successfully with google')
      expect(Openid.count).to eq(expected_count_openid)
      expect(User.count).to eq(expected_count_user)
    end

    it 'can handle authentication error' do
      OmniAuth.config.mock_auth[:google] = :invalid_credentials
      visit '/accounts/sign_in'
      expect(page.has_content?('Or use your openID')).to be true
      click_link 'google'
      expect(flash).to eq("Could not authenticate you from Google because \"Invalid credentials\".")
    end

    it 'adds openid to existing user' do
      # Sign in user
      user = create(:participant, email: 'test-participant-1@google.com')
      sign_in user

      # Add openID to current user
      expected_count_openid = Openid.count + 1
      expected_count_user = User.count
      visit '/accounts/edit'

      mock_auth_new_user
      click_link 'google'
      expect(flash).to eq('test-participant-1@google.com signed in successfully with google')
      expect(Openid.count).to eq(expected_count_openid)
      expect(User.count).to eq(expected_count_user)
      expect(Openid.where(email: 'test-1@gmail.com').first.nil?).to eq(false)
    end

    it 'signs in with openID using the same email as another associated openid' do |user|
      # Sign in user
      user = create(:participant, email: 'test-participant-1@google.com')
      expected_count_openid = Openid.count + 1
      expected_count_user = User.count
      visit '/accounts/sign_in'

      mock_auth_existing_user_participant
      click_link 'google'
      expect(flash).to eq('test-participant-1@google.com signed in successfully with google')
      expect(Openid.count).to eq(expected_count_openid)
      expect(User.count).to eq(expected_count_user)

      # Add openID to current user with email test-1@gmail.com
      expected_count_openid = Openid.count + 1
      expected_count_user = User.count
      visit '/accounts/edit'

      mock_auth_new_user
      click_link 'google'
      expect(flash).to eq('test-participant-1@google.com signed in successfully with google')
      expect(Openid.count).to eq(expected_count_openid)
      expect(User.count).to eq(expected_count_user)
      expect(Openid.where(email: 'test-participant-1@google.com').first.nil?).to eq(false)
      expect(Openid.where(email: 'test-1@gmail.com').first.nil?).to eq(false)

      # Sign in with different openID using same email (test-1@gmail.com)
      sign_out
      expected_count_openid = Openid.count + 1
      expected_count_user = User.count

      visit '/accounts/sign_in'
      mock_auth_new_user_fb
      click_link 'facebook'
      expect(flash).to eq('test-participant-1@google.com signed in successfully with facebook')
      expect(Openid.count).to eq(expected_count_openid)
      expect(User.count).to eq(expected_count_user)
      last_openid = Openid.last
      expect(last_openid.uid).to eq('facebook-test-uid-1')
      expect(last_openid.email).to eq('test-1@gmail.com')
    end
  end
end
