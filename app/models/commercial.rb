class Commercial < ActiveRecord::Base
  require 'oembed'

  belongs_to :commercialable, polymorphic: true

  attr_accessible :url

  validates :url, presence: true
  validates :url, format: URI::regexp(%w(http https))

  def self.provider
    {
      youtube: 'YouTube',
      slideshare: 'SlideShare',
      flickr: 'Flickr',
      vimeo: 'Vimeo',
      speakerdeck: 'Speakerdeck',
      instagram: 'Instagram'
    }
  end

  def self.get_content(url)
    speakerdeck = OEmbed::Provider.new('http://speakerdeck.com/oembed.json')
    speakerdeck << 'https://speakerdeck.com/*'
    speakerdeck << 'http://speakerdeck.com/*'

    OEmbed::Providers.register(
        OEmbed::Providers::Youtube,
        OEmbed::Providers::Vimeo,
        OEmbed::Providers::Slideshare,
        OEmbed::Providers::Flickr,
        OEmbed::Providers::Instagram,
        speakerdeck
    )

    begin
      resource = OEmbed::Providers.get(url, maxwidth: 560, maxheight: 315)
      resource.html
    rescue StandardError
      ''
    end
  end
end
