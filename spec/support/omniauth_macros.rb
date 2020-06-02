# frozen_string_literal: true

module OmniauthMacros
  # The mock_auth configuration allows you to set per-provider (or default)
  # authentication hashes to return during integration testing.

  ENV['OSEM_GOOGLE_KEY'] = 'test key google'
  ENV['OSEM_GOOGLE_SECRET'] = 'test secret google'
  # ENV['OSEM_FACEBOOK_KEY'] = 'test key facebook'
  # ENV['OSEM_FACEBOOK_SECRET'] = 'test secret facebook'
  # ENV['OSEM_SUSE_KEY'] = 'test key suse'
  # ENV['OSEM_SUSE_SECRET'] = 'test secret suse'
  # ENV['OSEM_GITHUB_KEY'] = 'test key github'
  # ENV['OSEM_GITHUB_SECRET'] = 'test secret github'

  def mock_auth_new_user
    OmniAuth.config.mock_auth[:google] =
      OmniAuth::AuthHash.new(
                              provider:    'google',
                              uid:         'google-test-uid-1',
                              info:        {
                                name:  'new user name',
                                email: 'test-1@example.com'
                              },
                              credentials: {
                                token:  'mock_token',
                                secret: 'mock_secret'
                              }
                            )
  end

  def mock_auth_new_user_fb
    OmniAuth.config.mock_auth[:facebook] =
      OmniAuth::AuthHash.new(
                              provider:    'facebook',
                              uid:         'facebook-test-uid-1',
                              info:        {
                                name:  'new user fb name',
                                email: 'test-1@example.com'
                              },
                              credentials: {
                                token:  'mock_token',
                                secret: 'mock_secret'
                              }
                            )
  end

  def mock_auth_existing_user_participant
    # The mock_auth configuration allows you to set per-provider (or default)
    # authentication hashes to return during integration testing.
    OmniAuth.config.mock_auth[:google] =
      OmniAuth::AuthHash.new(
                              provider:    'google',
                              uid:         'google-test-uid-participant-1',
                              info:        {
                                name:  'existing user participant name',
                                email: 'test-participant-1@example.com'
                              },
                              credentials: {
                                token:  'mock_token',
                                secret: 'mock_secret'
                              }
                            )
  end

  def mock_auth_existing_user_admin
    # The mock_auth configuration allows you to set per-provider (or default)
    # authentication hashes to return during integration testing.
    OmniAuth.config.mock_auth[:google] =
      OmniAuth::AuthHash.new(
                              provider:    'google',
                              uid:         'google-test-uid-admin-1',
                              info:        {
                                name:  'existing user admin name',
                                email: 'test-admin-1@example.com'
                              },
                              credentials: {
                                token:  'mock_token',
                                secret: 'mock_secret'
                              }
                            )
  end

  # We use these mock accounts to ensure that the ones which are available in
  # development are valid, to test omniauth actions and verify that a mock
  # account is available for every supported omniauth provider.
  # These must be identical to the ones in /config/environments/development.rb
  # Remember to keep them in sync with development.rb
  def mock_auth_accounts
    OmniAuth.config.mock_auth[:facebook] =
      OmniAuth::AuthHash.new(
                              provider:    'facebook',
                              uid:         'facebook-test-uid-1',
                              info:        {
                                name:     'facebook user',
                                email:    'user-facebook@example.com',
                                username: 'user_facebook'
                              },
                              credentials: {
                                token:  'fb_mock_token',
                                secret: 'fb_mock_secret'
                              }
                            )

    OmniAuth.config.mock_auth[:google] =
      OmniAuth::AuthHash.new(
                              provider:    'google',
                              uid:         'google-test-uid-1',
                              info:        {
                                name:     'google user',
                                email:    'user-google@example.com',
                                username: 'user_google'
                              },
                              credentials: {
                                token:  'google_mock_token',
                                secret: 'google_mock_secret'
                              }
                            )

    OmniAuth.config.mock_auth[:suse] =
      OmniAuth::AuthHash.new(
                              provider:    'suse',
                              uid:         'suse-test-uid-1',
                              info:        {
                                name:     'suse user',
                                email:    'user-suse@example.com',
                                username: 'user_suse'
                              },
                              credentials: {
                                token:  'suse_mock_token',
                                secret: 'suse_mock_secret'
                              }
                            )

    OmniAuth.config.mock_auth[:github] =
      OmniAuth::AuthHash.new(
                              provider:    'github',
                              uid:         'github-test-uid-1',
                              info:        {
                                name:     'github user',
                                email:    'user-github@example.com',
                                username: 'user_github'
                              },
                              credentials: {
                                token:  'github_mock_token',
                                secret: 'github_mock_secret'
                              }
                            )
  end
end
