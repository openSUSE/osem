# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

describe  External::MailblusterHelper, type: :helper do
  let!(:user) { create(:user) }

  describe 'create_lead' do
    it 'makes a post request to Mailbluster\'s API' do
      stub_request(:post, "http://api.mailbluster.com/api/leads")
        .to_return(body: `{
          "message": "Lead created",
          "lead": {
            "id": 329395,
            "firstName": "#{user.name}",
            "lastName": "",
            "fullName": "#{user.name}",
            "email": "#{user.email}",
            "subscribed": true,
            "tags": [
              "snapcon"
            ],
          }
        }`, status: 200)
      create_lead(user)
      expect(WebMock).to have_requested(:post, "api.mailbluster.com/api/leads").with(body: {
        'email': user.email,
        'firstName': user.name,
        'overrideExisting': true,
        'subscribed': true,
        'tags': ["snapcon"],
      }.to_json)
    end
  end
end
