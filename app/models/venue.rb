class Venue < ActiveRecord::Base
  belongs_to :conference
  has_many :lodgings
  before_create :generate_guid

  attr_accessible :name, :street, :postalcode, :city, :country, :longitude, :latitude, :description, :website, :photo, :lodgings_attributes, :conference_id
  validates :name, :street, :city, :country, presence: true

  has_attached_file :photo,
                    styles: { thumb: '100x100>', large: '300x300>' }
  validates_attachment_content_type :photo,
                                    content_type: [/jpg/, /jpeg/, /png/, /gif/],
                                    size: { in: 0..500.kilobytes }

  accepts_nested_attributes_for :lodgings, allow_destroy: true

  after_update :send_mail_notification

  def address
    "#{street}, #{city}, #{country_name}"
  end

  def country_name
    name = ISO3166::Country[country]
    name.name if name
  end

  private

  def send_mail_notification
    Mailbot.delay.send_email_on_venue_update(conference) if venue_notify?(conference)
  end

  def venue_notify?(conference)
    (self.name_changed? || self.street_changed?) &&
    (!self.name.blank? && !self.street.blank?) &&
    (conference.email_settings.send_on_venue_update &&
    !conference.email_settings.venue_update_subject.blank? &&
    conference.email_settings.venue_update_template)
  end

  # TODO: create a module to be mixed into model to perform same operation
  # event.rb has same functionality which can be shared
  # TODO: rename guid to UUID as guid is specifically Microsoft term
  def generate_guid
    loop do
      @guid = SecureRandom.urlsafe_base64
      break if !Venue.where(guid: guid).any?
    end
    self.guid = @guid
  end
end
