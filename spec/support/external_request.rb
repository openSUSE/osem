# frozen_string_literal: true

# Mock external requests to youtube
require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:each) do
    mock_commercial_request
  end
end

def mock_commercial_request
  response = {
    author_name:      'Confreaks',
    html:             '<iframe width="560" height="315" frameborder="0" allowfullscreen></iframe>',
    thumbnail_width:  480,
    thumbnail_url:    '/images/rails.png',
    provider_name:    'YouTube',
    width:            459,
    type:             'video',
    provider_url:     'http://www.youtube.com/',
    version:          '1.0',
    thumbnail_height: 360,
    title:            'RailsConf 2014 - Closing Keynote by Aaron Patterson',
    author_url:       'https://www.youtube.com/user/Confreaks',
    height:           344
  }
  WebMock.stub_request(:get, /.*youtube.*/)
    .to_return(status: 200, body: response.to_json, headers: {})
end
