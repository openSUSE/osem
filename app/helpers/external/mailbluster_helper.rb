# frozen_string_literal: true

module External
  module MailblusterHelper
    MAILBLUSTER_URL = 'https://api.mailbluster.com/api/leads/'

    # def query_api(user, method)
    # TODO? General helper for all queries
    # end

    def create_lead(user)
      uri = URI(MAILBLUSTER_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.path,
                                    'Authorization' => ENV['MAILBLUSTER_API_KEY'])
      request['Content-Type'] = 'application/json'
      request.body = {
        'email'            => user.email,
        'firstName'        => user.name,
        'overrideExisting' => true,
        'subscribed'       => true,
        'tags'             => ['snapcon']
      }.to_json
      response = http.request(request)
      response.body
    rescue StandardError => e
      puts "ERROR #{e}"
      nil
    end

    def delete_lead(user)
      email_hash = Digest::MD5.hexdigest user.email
      uri = URI(MAILBLUSTER_URL + email_hash)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Delete.new(uri.path,
                                    'Authorization' => ENV['MAILBLUSTER_API_KEY'])
      request['Content-Type'] = 'application/json'
      response = http.request(request)
      response.body
    rescue StandardError => e
      puts "ERROR #{e}"
      nil
    end
  end
end
