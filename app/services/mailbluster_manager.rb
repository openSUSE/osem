class MailblusterManager
  include HTTParty
  base_uri 'https://api.mailbluster.com/api/leads/'
  @auth_headers = {
    headers: {
      'Content-Type'  => 'application/json',
      'Authorization' => ENV['MAILBLUSTER_API_KEY']
    }
  }

  def self.query_api(method, path, body: {})
    options = @auth_headers.merge(body: body.to_json)
    send(method, path, options).parsed_response
  end

  def self.create_lead(user)
    query_api(:post, '/', body: {
                'email'            => user.email,
                'firstName'        => user.name,
                'overrideExisting' => true,
                'subscribed'       => true,
                'tags'             => [ENV['OSEM_NAME'] || 'snapcon']
              })
  end

  def self.edit_lead(user, add_tags: [], remove_tags: [], old_email: nil)
    email_hash = Digest::MD5.hexdigest(old_email.presence || user.email)
    query_api(:put, "/#{email_hash}", body: {
                'email'      => user.email,
                'firstName'  => user.name,
                'addTags'    => add_tags,
                'removeTags' => remove_tags
              })
  end

  def self.delete_lead(email)
    email_hash = Digest::MD5.hexdigest email
    query_api(:delete, "/#{email_hash}")
  end
end
