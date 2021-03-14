# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

describe  External::MailblusterHelper, type: :helper do
  let!(:user) { create(:user) }

  describe 'create_lead' do
    it 'makes a post request to Mailbluster\'s API' do
      stub_request(:post, "http://api.mailbluster.com/api/leads")
        .to_return(body: '{
          "message": "Lead created",
          "lead": {
            "id": 329395,
            "firstName": "Richard",
            "lastName": "Hendricks",
            "fullName": "Richard Hendricks",
            "email": "richard@example.com",
            "timezone": "America/Los_Angeles",
            "ipAddress": "162.213.1.246",
            "subscribed": false,
            "meta": {
              "company": "Pied Piper",
              "role": "CEO",
              "continent": "North America",
              "country": "United States",
              "city": "San Jose",
              "latitude": 37.3008,
              "longitude": -121.9777,
              "source": "Lead API"
            },
            "tags": [
              "iPhone User",
              "Startup"
            ],
            "createdAt": "2016-07-23T08:03:18.954Z",
            "updatedAt": "2016-07-23T08:03:18.954Z"
          }
        }', status: 200)
      create_lead(user)
      expect(WebMock).to have_requested(:post, "api.mailbluster.com/api/leads")
    end
  end
end
