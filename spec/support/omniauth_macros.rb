module OmniauthMacros
  # The mock_auth configuration allows you to set per-provider (or default)
  # authentication hashes to return during integration testing.

  Rails.application.secrets.google_key = 'test key google'
  Rails.application.secrets.google_secret = 'test secret google'
  Rails.application.secrets.facebook_key = 'test key facebook'
  Rails.application.secrets.facebook_secret = 'test secret facebook'

  def mock_auth_new_user
    OmniAuth.config.mock_auth[:google] =
      OmniAuth::AuthHash.new(
                              provider: 'google',
                              uid: 'google-test-uid-1',
                              info: {
                                name: 'new user name',
                                email: 'test-1@gmail.com'
                              },
                              credentials: {
                                token: 'mock_token',
                                secret: 'mock_secret'
                              }
                            )
  end

  def mock_auth_new_user_fb
    OmniAuth.config.mock_auth[:facebook] =
      OmniAuth::AuthHash.new(
                              provider: 'facebook',
                              uid: 'facebook-test-uid-1',
                              info: {
                                name: 'new user fb name',
                                email: 'test-1@gmail.com'
                              },
                              credentials: {
                                token: 'mock_token',
                                secret: 'mock_secret'
                              }
                            )
  end

  def mock_auth_existing_user_participant
    # The mock_auth configuration allows you to set per-provider (or default)
    # authentication hashes to return during integration testing.
    OmniAuth.config.mock_auth[:google] =
      OmniAuth::AuthHash.new(
                              provider: 'google',
                              uid: 'google-test-uid-participant-1',
                              info: {
                                name: 'existing user participant name',
                                email: 'test-participant-1@google.com'
                              },
                              credentials: {
                                token: 'mock_token',
                                secret: 'mock_secret'
                              }
                            )
  end

  def mock_auth_existing_user_admin
    # The mock_auth configuration allows you to set per-provider (or default)
    # authentication hashes to return during integration testing.
    OmniAuth.config.mock_auth[:google] =
      OmniAuth::AuthHash.new(
                              provider: 'google',
                              uid: 'google-test-uid-admin-1',
                              info: {
                                name: 'existing user admin name',
                                email: 'test-admin-1@google.com'
                              },
                              credentials: {
                                token: 'mock_token',
                                secret: 'mock_secret'
                              }
                            )
  end
end
