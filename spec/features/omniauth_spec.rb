# frozen_string_literal: true

require 'spec_helper'

feature Openid, type: :feature, js: true do
  shared_examples 'sign in with openid' do

    scenario 'has option to log in with Google account' do
      visit '/accounts/sign_in'
      expect(page.has_content?('or sign in using')).to be true
      expect(page.has_link?('omniauth-google')).to be true
    end

    scenario 'signs in *new* user with Google account' do
      expected_count_openid = Openid.count + 1
      expected_count_user = User.count + 1
      visit '/accounts/sign_in'

      mock_auth_new_user
      within('#openidlinks') do
        click_link 'omniauth-google'
      end
      page.find('#flash')
      expect(flash).to eq('test-1@example.com signed in successfully with google')
      expect(Openid.count).to eq(expected_count_openid)
      expect(User.count).to eq(expected_count_user)
    end

    scenario 'signs in an existing user' do
      create(:user, email: 'test-participant-1@example.com')
      expected_count_openid = Openid.count + 1
      expected_count_user = User.count
      visit '/accounts/sign_in'

      mock_auth_existing_user_participant
      within('#openidlinks') do
        click_link 'omniauth-google'
      end
      page.find('#flash')
      expect(flash).to eq('test-participant-1@example.com signed in successfully with google')
      expect(Openid.count).to eq(expected_count_openid)
      expect(User.count).to eq(expected_count_user)
    end

    scenario 'can handle authentication error' do
      OmniAuth.config.mock_auth[:google] = :invalid_credentials
      visit '/accounts/sign_in'
      expect(page.has_content?('or sign in using')).to be true
      within('#openidlinks') do
        click_link 'omniauth-google'
      end
      page.find('#flash')
      expect(flash).to eq('Could not authenticate you from Google because "Invalid credentials".')
    end

    scenario 'adds openid to existing user' do
      # Sign in user
      user = create(:user, email: 'test-participant-1@example.com')
      sign_in user

      # Add openID to current user
      expected_count_openid = Openid.count + 1
      expected_count_user = User.count
      visit '/accounts/edit'

      mock_auth_new_user
      within('#openidlinks') do
        click_link 'omniauth-google'
      end
      page.find('#flash')
      expect(flash).to eq('test-participant-1@example.com signed in successfully with google')
      expect(Openid.count).to eq(expected_count_openid)
      expect(User.count).to eq(expected_count_user)
      expect(Openid.where(email: 'test-1@example.com').first.nil?).to eq(false)
    end

    scenario 'signs in with openID using the same email as another associated openid' do
      # Sign in user
      create(:user, email: 'test-participant-1@example.com')
      expected_count_openid = Openid.count + 1
      expected_count_user = User.count
      visit '/accounts/sign_in'

      mock_auth_existing_user_participant
      within('#openidlinks') do
        click_link 'omniauth-google'
      end
      page.find('#flash')
      expect(flash).to eq('test-participant-1@example.com signed in successfully with google')
      page.find('#flash .close').click
      expect(Openid.count).to eq(expected_count_openid)
      expect(User.count).to eq(expected_count_user)

      # Add openID to current user with email test-1@gmail.com
      expected_count_openid = Openid.count + 1
      expected_count_user = User.count
      visit '/accounts/edit'

      mock_auth_new_user
      within('#openidlinks') do
        click_link 'omniauth-google'
      end
      page.find('#flash')
      expect(flash).to eq('test-participant-1@example.com signed in successfully with google')
      page.find('#flash .close').click
      expect(Openid.count).to eq(expected_count_openid)
      expect(User.count).to eq(expected_count_user)
      expect(Openid.where(email: 'test-participant-1@example.com').first.nil?).to eq(false)
      expect(Openid.where(email: 'test-1@example.com').first.nil?).to eq(false)

      # Sign in with different openID using same email (test-1@gmail.com)
      sign_out
      expected_count_openid = Openid.count + 1
      expected_count_user = User.count

      visit '/accounts/sign_in'
      mock_auth_new_user_fb
      within('#openidlinks') do
        click_link 'omniauth-facebook'
      end
      page.find('#flash')
      expect(flash).to eq('test-participant-1@example.com signed in successfully with facebook')
      expect(Openid.count).to eq(expected_count_openid)
      expect(User.count).to eq(expected_count_user)
      last_openid = Openid.last
      expect(last_openid.uid).to eq('facebook-test-uid-1')
      expect(last_openid.email).to eq('test-1@example.com')
    end
  end

  shared_examples 'sign up with openid' do |provider|
    scenario "has option to sign in with #{provider}" do
      visit '/accounts/sign_up'
      expect(page.has_content?('or sign in using')).to eq true
      expect(page.has_link?("omniauth-#{provider}")).to eq true
    end

    scenario "sign up with #{provider}" do
      expected_count_openid = Openid.count + 1
      expected_count_user = User.count + 1
      visit '/accounts/sign_up'

      mock_auth_accounts
      within('#openidlinks') do
        click_link "omniauth-#{provider}"
      end
      page.find('#flash')
      expect(flash).to eq("user-#{provider}@example.com signed in successfully with #{provider}")
      expect(Openid.count).to eq(expected_count_openid)
      expect(User.count).to eq(expected_count_user)
    end
  end

  describe 'omniauth' do
    if User.omniauth_providers.present?
      it_behaves_like 'sign in with openid'

      User.omniauth_providers.each do |provider|
        it_behaves_like 'sign up with openid', provider
      end
    end
  end
end
