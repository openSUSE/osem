class MailblusterManager
  include HTTParty
  base_uri 'https://api.mailbluster.com/api/leads/'
  @@auth_headers = {
    headers: {
      'Content-Type'  => 'application/json',
      'Authorization' => ENV['MAILBLUSTER_API_KEY']
    }
  }

  def query_api(method, user, body)
    #TODO
  end

  def self.create_lead(user)
    options = @@auth_headers.merge({
      body:    {
        'email'            => user.email,
        'firstName'        => user.name,
        'overrideExisting' => true,
        'subscribed'       => true,
        'tags'             => [ENV['OSEM_NAME'] || 'snapcon']
      }.to_json
    })
    post('/', options).parsed_response
  end

  def self.edit_lead(user, add_tags: [], remove_tags: [], old_email: nil)
    options = @@auth_headers.merge({
      body:    {
        'email'      => user.email,
        'firstName'  => user.name,
        'addTags'    => add_tags,
        'removeTags' => remove_tags
      }.to_json
    })
    email_hash = Digest::MD5.hexdigest(old_email.presence || user.email)
    put("/#{email_hash}", options).parsed_response
  end

  def self.delete_lead(user)
    email_hash = Digest::MD5.hexdigest user.email
    options = @@auth_headers
    delete("/#{email_hash}", options).parsed_response
  end
end
