module OmniauthMacros
  # The mock_auth configuration allows you to set per-provider (or default)
  # authentication hashes to return during integration testing.

  def mock_auth_new_user
    OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
      provider: 'google',
      uid: 'google-test-uid-1',
      info: {
        email: 'test-1@gmail.com'
      },
      credentials: {
        token: 'mock_token',
        secret: 'mock_secret'
      }
    })
  end

    def mock_auth_new_user_fb
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
      provider: 'google',
      uid: 'facebook-test-uid-1',
      info: {
        email: 'test-1@gmail.com'
      },
      credentials: {
        token: 'mock_token',
        secret: 'mock_secret'
      }
    })
  end

  def mock_auth_existing_user_participant
    # The mock_auth configuration allows you to set per-provider (or default)
    # authentication hashes to return during integration testing.
    OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
      provider: 'google',
      uid: 'google-test-uid-participant-1',
      info: {
        email: 'test-participant-1@google.com'
      },
      credentials: {
        token: 'mock_token',
        secret: 'mock_secret'
      }
    })
  end

  def mock_auth_existing_user_admin
    # The mock_auth configuration allows you to set per-provider (or default)
    # authentication hashes to return during integration testing.
    OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
      provider: 'google',
      uid: 'google-test-uid-admin-1',
      info: {
        email: 'test-admin-1@google.com'
      },
      credentials: {
        token: 'mock_token',
        secret: 'mock_secret'
      }
    })
  end
end