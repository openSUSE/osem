class Conference < ActiveRecord::Base
  attr_accessible :title, :short_title, :social_tag, :contact_email, :timezone, :html_export_path,
                  :start_date, :end_date, :rooms_attributes, :tracks_attributes, :dietary_choices_attributes,
                  :use_dietary_choices, :use_supporter_levels, :supporter_levels_attributes, :social_events_attributes,
                  :event_types_attributes, :registration_start_date, :registration_end_date, :logo,
		  :questions_attributes, :question_ids, :answers_attributes, :answer_ids,
                  :difficulty_levels_attributes, :use_difficulty_levels,
                  :use_vpositions, :use_vdays, :vdays_attributes, :vpositions_attributes

  has_paper_trail

  has_and_belongs_to_many :questions

  has_one :email_settings, :dependent => :destroy
  has_one :call_for_papers, :dependent => :destroy
  has_many :social_events, :dependent => :destroy
  has_many :supporter_registrations, :dependent => :destroy
  has_many :supporter_levels, :dependent => :destroy
  has_many :dietary_choices, :dependent => :destroy
  has_many :events, :dependent => :destroy
  has_many :event_types, :dependent => :destroy
  has_many :tracks, :dependent => :destroy
  has_many :difficulty_levels, :dependent => :destroy
  has_many :rooms, :dependent => :destroy
  has_many :registrations, :dependent => :destroy
  has_many :vdays, :dependent => :destroy
  has_many :vpositions, :dependent => :destroy
  has_many :vchoices, :dependent => :destroy

  belongs_to :venue

  accepts_nested_attributes_for :rooms, :reject_if => proc {|r| r["name"].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :tracks, :reject_if => proc {|r| r["name"].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :difficulty_levels, :allow_destroy => true
  accepts_nested_attributes_for :social_events, :allow_destroy => true
  accepts_nested_attributes_for :venue
  accepts_nested_attributes_for :dietary_choices, :allow_destroy => true
  accepts_nested_attributes_for :supporter_levels, :allow_destroy => true
  accepts_nested_attributes_for :event_types, :allow_destroy => true
  accepts_nested_attributes_for :email_settings
  accepts_nested_attributes_for :questions, :allow_destroy => true
  accepts_nested_attributes_for :vdays, :allow_destroy => true
  accepts_nested_attributes_for :vpositions, :allow_destroy => true

  has_attached_file :logo,
                    :styles => {:thumb => "100x100>", :large => "300x300>" }

  validates_attachment_content_type :logo,
                                    :content_type => [/jpg/, /jpeg/, /png/, /gif/],
                                    :size => { :in => 0..500.kilobytes }

  validates_presence_of :title,
                        :short_title,
                        :social_tag
  validates_uniqueness_of :short_title
  validates_format_of :short_title, :with => /^[a-zA-Z0-9_-]*$/
   
  before_create :generate_guid
  before_create :create_venue
  before_create :create_email_settings

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

  def registration_open?
    today = Date.current
    if self.registration_start_date.nil? || self.registration_end_date.nil?
      false
    end

    (registration_start_date..registration_end_date).cover?(today)
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

  def create_email_settings
    build_email_settings
    true
  end
  def generate_guid
    begin
      guid = SecureRandom.urlsafe_base64
    end while Person.where(:guid => guid).exists?
    self.guid = guid
  end

end
