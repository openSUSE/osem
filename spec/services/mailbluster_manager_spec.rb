# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

describe MailblusterManager, type: :model do
  let!(:user) { create(:user) }

  before(:each) do
    WebMock.reset_executed_requests!
  end

  url = 'https://api.mailbluster.com/api/leads/'

  describe 'query_api' do
    it 'translates :get to a get request' do
      stub_request(:get, url)
      described_class.query_api(:get, '/')

      expect(WebMock).to have_requested(:get, url)
    end

    it 'translates :post to a post request' do
      stub_request(:post, url + 'path')
      described_class.query_api(:post, '/path', body: { key: 'value' })

      expect(WebMock).to have_requested(:post, url + 'path').with(body: { key: 'value' })
    end
  end

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
            #{ENV['OSEM_NAME'] || 'snapcon'}
          ],
        }
      }"
      stub_request(:post, url)
        .to_return(body: response_body, status: 200)
      response = described_class.create_lead(user)

      expect(WebMock).to have_requested(:post, url).with(body: {
        'email':            user.email,
        'firstName':        user.name,
        'overrideExisting': true,
        'subscribed':       true,
        'tags':             [ENV['OSEM_NAME'] || 'snapcon']
      }.to_json)
      expect(response).to eq(response_body)
    end
  end

  describe 'edit_lead' do
    it 'makes a put request to Mailbluster\'s API to change the email and gets the correct response' do
      response_body = "{
        \"message\": \"Lead updated\",
        \"lead\": {
          \"id\": 329395,
          \"firstName\": \"#{user.name}\",
          \"lastName\": \"\",
          \"fullName\": \"#{user.name}\",
          \"email\": \"#{user.email}\",
          \"subscribed\": true,
          \"tags\": [
            #{ENV['OSEM_NAME'] || 'snapcon'}
          ],
        }
      }"
      old_email = user.email
      user.email = 'new@new.org'
      user.save
      stub_request(:put, url + Digest::MD5.hexdigest(old_email))
        .to_return(body: response_body, status: 200)
      response = described_class.edit_lead(user, old_email: old_email)

      expect(WebMock).to have_requested(:put, url + Digest::MD5.hexdigest(old_email)).with(body: {
        'email':      user.email,
        'firstName':  user.name,
        'addTags':    [],
        'removeTags': []
      }.to_json)
      expect(response).to eq(response_body)
    end

    it 'makes a put request to Mailbluster\'s API to add a tag and gets the correct response' do
      response_body = "{
        \"message\": \"Lead updated\",
        \"lead\": {
          \"id\": 329395,
          \"firstName\": \"#{user.name}\",
          \"lastName\": \"\",
          \"fullName\": \"#{user.name}\",
          \"email\": \"#{user.email}\",
          \"subscribed\": true,
          \"tags\": [
            #{ENV['OSEM_NAME'] || 'snapcon'}, '2021'
          ],
        }
      }"
      stub_request(:put, url + Digest::MD5.hexdigest(user.email))
        .to_return(body: response_body, status: 200)
      add_tags = ['2021']
      response = described_class.edit_lead(user, add_tags: add_tags)

      expect(WebMock).to have_requested(:put, url + Digest::MD5.hexdigest(user.email)).with(body: {
        'email':      user.email,
        'firstName':  user.name,
        'addTags':    add_tags,
        'removeTags': []
      }.to_json)
      expect(response).to eq(response_body)
    end
  end

  describe 'delete_lead' do
    it 'correctly requests the right URL and gets a valid response' do
      email_hash = Digest::MD5.hexdigest user.email
      response_body = "{
        \"message\":\"Lead deleted\",
        \"leadHash\":\"#{email_hash}\"
      }"
      lead_url = url + email_hash.to_s
      stub_request(:delete, lead_url)
        .to_return(body: response_body)
      response = described_class.delete_lead(user.email)

      expect(WebMock).to have_requested(:delete, lead_url)
      expect(response).to eq(response_body)
    end
  end
end
