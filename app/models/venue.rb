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

  private

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
