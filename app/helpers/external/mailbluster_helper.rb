# frozen_string_literal: true

require 'httparty'

module External
  module MailblusterHelper
    MAILBLUSTER_URL = 'https://api.mailbluster.com/api/leads/'

    # def query_api(user, method)
    # TODO? General helper for all queries
    # end

    def create_lead(user)
      options = {
        headers: {
          'Content-Type'  => 'application/json',
          'Authorization' => ENV['MAILBLUSTER_API_KEY']
        },
        body:    {
          'email'            => user.email,
          'firstName'        => user.name,
          'overrideExisting' => true,
          'subscribed'       => true,
          'tags'             => [ENV['OSEM_NAME'] || 'snapcon']
        }.to_json
      }
      HTTParty.post(MAILBLUSTER_URL, options).parsed_response
    rescue StandardError => e
      puts "ERROR #{e}"
      nil
    end

    def edit_lead(user, add_tags: [], remove_tags: [], old_email: nil)
      options = {
        headers: {
          'Content-Type'  => 'application/json',
          'Authorization' => ENV['MAILBLUSTER_API_KEY']
        },
        body:    {
          'email'            => user.email,
          'firstName'        => user.name,
          'addTags'          => add_tags,
          'removeTags'       => remove_tags
        }.to_json
      }
      email_hash = Digest::MD5.hexdigest(old_email.presence || user.email)
      HTTParty.put(MAILBLUSTER_URL + email_hash, options).parsed_response
    end

    def delete_lead(user)
      email_hash = Digest::MD5.hexdigest user.email
      options = {
        headers: {
          'Content-Type'  => 'application/json',
          'Authorization' => ENV['MAILBLUSTER_API_KEY']
        }
      }
      HTTParty.delete(MAILBLUSTER_URL + email_hash, options).parsed_response
    rescue StandardError => e
      puts "ERROR #{e}"
      nil
    end
  end
end
