# frozen_string_literal: true

# == Schema Information
#
# Table name: venues
#
#  id              :bigint           not null, primary key
#  city            :string
#  country         :string
#  description     :text
#  guid            :string
#  latitude        :string
#  longitude       :string
#  name            :string
#  photo_file_name :string
#  picture         :string
#  postalcode      :string
#  street          :string
#  website         :string
#  created_at      :datetime
#  updated_at      :datetime
#  conference_id   :integer
#
class Venue < ApplicationRecord
  belongs_to :conference
  has_one :commercial, as: :commercialable, dependent: :destroy
  has_many :rooms, dependent: :destroy
  before_create :generate_guid

  has_paper_trail ignore: [:updated_at, :guid], meta: { conference_id: :conference_id }

  accepts_nested_attributes_for :commercial, allow_destroy: true
  validates :name, :street, :city, :country, presence: true

  mount_uploader :picture, PictureUploader, mount_on: :photo_file_name

  before_save :send_mail_notification

  def address
    "#{street}, #{city}, #{country_name}"
  end

  def country_name
    name = ISO3166::Country[country]
    name&.name
  end

  def location?
    !(latitude.blank? || longitude.blank?)
  end

  private

  def send_mail_notification
    ConferenceVenueUpdateMailJob.perform_later(conference) if notify_on_venue_changed?
  end

  def notify_on_venue_changed?
    return false unless conference.try(:email_settings).try(:send_on_venue_updated)
    # do not notify unless the address changed
    return false unless saved_change_to_name? || saved_change_to_street? || saved_change_to_city? || saved_change_to_country?

    # do not notify unless the mail content is set up
    (!conference.email_settings.venue_updated_subject.blank? && !conference.email_settings.venue_updated_body.blank?)
  end

  # TODO: create a module to be mixed into model to perform same operation
  # event.rb has same functionality which can be shared
  # TODO: rename guid to UUID as guid is specifically Microsoft term
  def generate_guid
    loop do
      @guid = SecureRandom.urlsafe_base64
      break unless Venue.where(guid: guid).any?
    end
    self.guid = @guid
  end
end
