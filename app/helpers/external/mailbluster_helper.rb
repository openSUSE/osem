# frozen_string_literal: true

module External
  module MailblusterHelper
    def query_api()
      
    end

    def create_lead(user)
      # TODO
      begin
        uri = URI("http://api.mailbluster.com/api/leads")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.path,
          {'Authorization' => ENV["MAILBLUSTER_API_KEY"]}) # TODO Authorization=APIKEY
        request.body = {
            'email' => user.email,
            'firstName' => user.name,
            'overrideExisting' => true,
            'subscribed' => true,
            'tags' => ["snapcon"],
        }.to_json
        response = http.request(request)
        # puts request.body.to_json
        # puts response.body.to_json
        return response.to_json
      rescue => e
        puts "ERROR #{e}"
        return nil
      end
    end

    def delete_lead(user)

    end
  end
end
