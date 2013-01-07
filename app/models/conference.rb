class Conference < ActiveRecord::Base
  attr_accessible :title, :short_title, :social_tag, :contact_email, :timezone, :html_export_path,
                  :start_date, :end_date, :rooms_attributes, :tracks_attributes, :cfp_open, :registration_open,
                  :event_types_attributes

  has_one :call_for_papers, :dependent => :destroy
  has_many :events, :dependent => :destroy
  has_many :event_types, :dependent => :destroy
  has_many :tracks, :dependent => :destroy
  has_many :rooms, :dependent => :destroy
  has_many :registrations, :dependent => :destroy

  belongs_to :venue

  accepts_nested_attributes_for :rooms, :reject_if => proc {|r| r["name"].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :tracks, :reject_if => proc {|r| r["name"].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :venue
  accepts_nested_attributes_for :event_types, :allow_destroy => true

  validates_presence_of :title,
                        :short_title,
                        :social_tag
  validates_uniqueness_of :short_title
  validates_format_of :short_title, :with => /^[a-zA-Z0-9_-]*$/
  before_create :generate_guid
  before_create :create_venue


  def self.current
    self.order("created_at DESC").first
  end

  def date_range_string
    startstr = "Unknown - "
    endstr = "Unknown"
    if start_date.month == end_date.month && start_date.year == end_date.year
      startstr = start_date.strftime("%B %d - ")
      endstr = end_date.strftime("%d, %Y")
    elsif start_date.month != end_date.month && start_date.year == end_date.year
      startstr = start_date.strftime("%B %d - ")
      endstr = end_date.strftime("%B %d, %Y")
    else
      startstr = start_date.strftime("%B %d, %Y - ")
      endstr = end_date.strftime("%B %d, %Y")
    end

    result = startstr + endstr
    result
  end

  def user_registered? user
    return nil if user.nil?
    return nil if user.person.nil?

    if self.registrations.where(:person_id => user.person.id).count == 0
      Rails.logger.debug("Returning false")
      false
    else
      Rails.logger.debug("Returning true")
      true
    end
  end

  def cfp_open?
    today = Date.current
    cfp = self.call_for_papers
    if !cfp.nil? && (cfp.start_date.. cfp.end_date).cover?(today)
      return true
    end

    return false
  end
  private

  def create_venue
    self.venue_id = Venue.create.id
    true
  end

  def generate_guid
    begin
      guid = SecureRandom.urlsafe_base64
    end while Person.where(:guid => guid).exists?
    self.guid = guid
  end

end