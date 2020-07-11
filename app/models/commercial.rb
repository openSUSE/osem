# frozen_string_literal: true

class Commercial < ApplicationRecord
  require 'oembed'

  belongs_to :commercialable, polymorphic: true

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  validates :url, presence: true, uniqueness: { scope: :commercialable }
  validates :url, format: URI::regexp(%w(http https))

  validate :valid_url

  def self.render_from_url(url)
    register_provider
    begin
      resource = OEmbed::Providers.get(url, maxwidth: 560, maxheight: 315)
      { html: resource.html.html_safe }
    rescue StandardError => exception
      { html: iframe_fallback(url) }
      # { error: exception.message }
    end
  end

  def self.iframe_fallback(url)
    # <br><a href='#{url}' target=_blank>Open in a new tab</a>
    "<iframe src=\"#{url}\"></iframe>".html_safe
  end

  def self.read_file(file)
    errors = {}
    errors[:no_event] = []
    errors[:validation_errors] = []

    file.read.each_line do |line|
      # Get the event id (text before :)
      id = line.match(/:/).pre_match.to_i
      # Get the commercial url (text after :)
      url = line.match(/:/).post_match
      event = Event.find_by(id: id)

      # Go to next event, if the event is not found
      errors[:no_event] << id && next unless event

      commercial = event.commercials.new(url: url)
      unless commercial.save
        errors[:validation_errors] << "Could not create materials for event with ID #{event.id} (" + commercial.errors.full_messages.to_sentence + ')'
      end
    end
    errors
  end

  private

  def valid_url
    result = Commercial.render_from_url(url)
    if result[:error]
      errors.add(:base, result[:error])
    end
  end

  def self.register_provider
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
    # OEmbed::Providers.register_fallback(
    #   OEmbed::ProviderDiscovery,
    #   OEmbed::Providers::Noembed
    # )
  end

  def conference_id
    case commercialable_type
    when 'Conference' then commercialable_id
    when 'Event' then Event.find(commercialable_id).program.conference_id
    when 'Venue' then Venue.find(commercialable_id).conference_id
    end
  end
end
