# frozen_string_literal: true

module External
  module MailblusterHelper
    def create_lead(user)
      # TODO
      begin
        uri = URI("api.mailbluster.com/api/leads")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.path,
          {'Authorization' => ENV["MAILBLUSTER_API_KEY"]}) # TODO Authorization=APIKEY
        request.body = {'firstName' => user.name,
            'email' => user.email,
            'subscribed' => true,
            'tags' => ["snapcon"],
            'overrideExisting' => true}.to_json
        response = http.request(request)
        puts response
        return true
      rescue => e
        puts "ERROR #{e}"
        return false
      end
    end
  end
end
