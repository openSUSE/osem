class Venue < ActiveRecord::Base
  attr_accessible :name, :description, :website, :address, :photo, :lodgings_attributes,
                  :include_venue_in_splash, :include_lodgings_in_splash
  has_many :conferences
  has_many :lodgings
  before_create :generate_guid
  has_attached_file :photo,
                    styles: { thumb: '100x100>', large: '300x300>' }

  validates_attachment_content_type :photo,
                                    content_type: [/jpg/, /jpeg/, /png/, /gif/],
                                    size: { in: 0..500.kilobytes }
  accepts_nested_attributes_for :lodgings, allow_destroy: true

  after_update :send_mail_notification

  validates :name, :address, presence: true

  private

  def send_mail_notification
    conferences.each do |conference|
      Mailbot.delay.send_email_on_venue_update(conference) if venue_notify?(conference)
    end
  end

  def venue_notify?(conference)
    (self.name_changed? || self.address_changed?) &&
    (!self.name.blank? && !self.address.blank?) &&
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
