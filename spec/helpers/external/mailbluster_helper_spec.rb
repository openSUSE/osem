# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

describe  External::MailblusterHelper, type: :helper do
  let!(:user) { create(:user) }

  describe 'create_lead' do
    it 'makes a post request to Mailbluster\'s API' do
      create_lead(@user)
      expect(WebMock).to have_requested(:post, "api.mailbluster.com/api/leads").
        with { |req| req.body == "abc" }
    end
  end
end
