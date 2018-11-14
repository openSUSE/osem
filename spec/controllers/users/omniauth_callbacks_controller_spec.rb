# frozen_string_literal: true

require 'spec_helper'

describe Users::OmniauthCallbacksController do
  context 'email is not there in auth hash' do
    before do
      stub_env_for_omniauth
      get :google
    end

    it { expect(flash[:error]).to eq('Email field is missing in your google account') }
  end
end

def stub_env_for_omniauth
  request.env['devise.mapping'] = Devise.mappings[:user]
  env = OmniAuth::AuthHash.new(
                                provider:    'google',
                                uid:         'google-test-uid-1',
                                info:        {
                                  name:     'google user',
                                  email:    nil,
                                  username: 'user_google'
                                },
                                credentials: {
                                  token:  'google_mock_token',
                                  secret: 'google_mock_secret'
                                }
  )
  request.env['omniauth.auth'] = env
  allow(@controller).to receive(:env).and_return(env)
end
