# frozen_string_literal: true

module External
  module MailblusterHelper
    def create_lead(user)
      # TODO
      begin
        uri = URI("http://api.mailbluster.com/api/leads")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.path,
          {'Authorization' => ENV["MAILBLUSTER_API_KEY"]}) # TODO Authorization=APIKEY
        request.body = {'firstName' => user.name,
            'email' => user.email,
            'subscribed' => true,
            'tags' => ["snapcon"],
            'overrideExisting' => true}.to_json
        puts request.body.to_json
        response = http.request(request)
        puts response.body.to_json
        return response.to_json
      rescue => e
        puts "ERROR #{e}"
        return nil
      end
    end
  end
end
