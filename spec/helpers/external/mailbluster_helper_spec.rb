# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

describe External::MailblusterHelper, type: :helper do
  let!(:user) { create(:user) }

  describe 'create_lead' do
    it 'makes a post request to Mailbluster\'s API and gets the correct response' do
      response_body = "{
        \"message\": \"Lead created\",
        \"lead\": {
          \"id\": 329395,
          \"firstName\": \"#{user.name}\",
          \"lastName\": \"\",
          \"fullName\": \"#{user.name}\",
          \"email\": \"#{user.email}\",
          \"subscribed\": true,
          \"tags\": [
            \"snapcon\"
          ],
        }
      }"
      stub_request(:post, 'https://api.mailbluster.com/api/leads')
        .to_return(body: response_body, status: 200)
      response = create_lead(user)

      expect(WebMock).to have_requested(:post, 'api.mailbluster.com/api/leads').with(body: {
        'email':            user.email,
        'firstName':        user.name,
        'overrideExisting': true,
        'subscribed':       true,
        'tags':             ['snapcon']
      }.to_json)
      expect(response).to eq(response_body)
    end
  end

  describe 'delete_lead' do
    it 'correctly requests the right URL and gets a valid response' do
      email_hash = Digest::MD5.hexdigest user.email
      response_body = "{\"message\":\"Lead deleted\",\"leadHash\":\"#{email_hash}\"}"
      stub_request(:delete, "https://api.mailbluster.com/api/leads/#{email_hash}")
        .to_return(body: response_body)
      response = delete_lead(user)

      expect(WebMock).to have_requested(:delete, "api.mailbluster.com/api/leads/#{email_hash}")
      expect(response).to eq(response_body)
    end
  end
end
