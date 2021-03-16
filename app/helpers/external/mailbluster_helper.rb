# frozen_string_literal: true

module External
  module MailblusterHelper
    MAILBLUSTER_URL = 'https://api.mailbluster.com/api/leads'

    def query_api; end

    def create_lead(user)
      # TODO

      uri = URI(MAILBLUSTER_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path,
                                    'Authorization' => ENV['MAILBLUSTER_API_KEY']) # TODO: Authorization=APIKEY
      request.body = {
        'email'            => user.email,
        'firstName'        => user.name,
        'overrideExisting' => true,
        'subscribed'       => true,
        'tags'             => ['snapcon']
      }.to_json
      response = http.request(request)
      # puts request.body.to_json
      # puts response.body.to_json
      response.to_json
    rescue StandardError => e
      puts "ERROR #{e}"
      nil
    end

    def delete_lead(user)
      # TODO
    end
  end
end
