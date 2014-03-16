class Event < ActiveRecord::Base
  include ActiveRecord::Transitions
  has_paper_trail
  attr_accessible :title, :subtitle, :abstract, :description, :event_type_id, :people_attributes, :person, :proposal_additional_speakers, :track_id, :video_id, :video_type, :require_registration, :difficulty_level_id

  VIDEO_TYPE = [YOUTUBE = 'YouTube', SLIDE_SHARE = 'SlideShare', FLICKR = 'Flickr', VIMEO = 'Vimeo', SPEAKERDECK = 'Speakerdeck']

  validates :video_type, inclusion: {in: VIDEO_TYPE}

  acts_as_commentable

  has_many :event_people, :dependent => :destroy
  has_many :event_attachments, :dependent => :destroy
  has_many :people, :through => :event_people
  has_many :speakers, :through => :event_people, :source => :person, :conditions => {"event_people.event_role" => "speaker"}
  has_many :votes
  has_many :voters, :through => :votes, :source => :person
  belongs_to :event_type

  has_and_belongs_to_many :registrations

  belongs_to :track
  belongs_to :room
  belongs_to :difficulty_level
  belongs_to :conference

  accepts_nested_attributes_for :event_people, :allow_destroy => true
  accepts_nested_attributes_for :event_attachments, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :people
  before_create :generate_guid

  validate :abstract_limit
  validate :biography_exists
  validates :title, :presence => true
  validates :abstract, :presence => true

  scope :confirmed, where(:state => "confirmed")

  state_machine :initial => :new do
    state :new
    state :review
    state :withdrawn
    state :accepted
    state :unconfirmed
    state :confirmed
    state :canceled
    state :rejected

    event :start_review do
      transitions :to => :review, :from => [:new, :rejected, :canceled]
    end
    event :withdraw do
      transitions :to => :withdrawn, :from => [:new, :review, :unconfirmed, :confirmed]
    end
    event :accept do
      transitions :to => :unconfirmed, :from => [:new, :review], :on_transition => :process_acceptance
    end
    event :unconfirm do
      transitions :to => :review, :from=>[:confirmed]
    end
    event :confirm do
      transitions :to => :confirmed, :from => :unconfirmed, :on_transition => :process_confirmation
    end
    event :cancel do
      transitions :to => :canceled, :from => [:unconfirmed, :confirmed]
    end
    event :reject do
      transitions :to => :rejected, :from => [:new, :review], :on_transition => :process_rejection
    end
  end

  def voted?(event, person)
    event.votes.where("person_id = ?", person).first
  end
  
  def average_rating
    @total_rating = 0
    self.votes.each do |vote|
      @total_rating = @total_rating + vote.rating
    end
    @total = self.votes.size
    number_with_precision(@total_rating / @total.to_f, :precision => 2, :strip_insignificant_zeros => true)
  end

  def submitter
    result = self.event_people.where(:event_role => "submitter").first
    if !result.nil?
      result.person
    else
      person = nil
      # Perhaps the event_people haven't been saved, if this is a new proposal
      self.event_people.each do |p|
        if p.event_role == "submitter"
          person = p.person
        end
      end
      person
    end
  end

  def as_json(options)
    json = super(options)

    if self.room.nil?
      json[:room_guid] = nil
    else
      json[:room_guid] = self.room.guid
    end

    if self.track.nil?
      json[:track_color]  = "#ffffff"
    else
      json[:track_color] = self.track.color;
    end

    if self.event_type.nil?
      json[:length] = 25
    else
      json[:length] = self.event_type.length
    end

    json
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(self.current_state).include?(transition)
  end

  def process_confirmation(options)
    if self.conference.email_settings.send_on_confirmed_without_registration?
      if self.conference.registrations.where(:person_id => self.submitter.id).first.nil?
        Mailbot.confirm_reminder_mail(self).deliver
      end
    end
  end

  def process_acceptance(options)
    if options[:send_mail] == "true"
      Rails.logger.debug "Sending acceptance mail"
      Mailbot.acceptance_mail(self).deliver
    end
  end

  def process_rejection(options)
    if options[:send_mail] == "true"
      Mailbot.rejection_mail(self).deliver
    end
  end

  def public_state
    public_state = "Submitted"
    case self.state
      when "withdrawn"
        public_state = "Withdrawn"
      when "new", "review"
        public_state = "Review Pending"
      when "accepted", "unconfirmed"
        public_state = "Accepted (confirmation pending)"
      when "confirmed"
        public_state = "Confirmed"
      when "rejected"
        public_state = "Rejected"
      when "cancelled"
        public_state = "Cancelled"
    end
    public_state
  end

  def abstract_word_count
    if self.abstract.nil?
      0
    else
      self.abstract.split.size
    end
  end

  private

  def abstract_limit
    len = self.abstract.split.size
    max = self.event_type.maximum_abstract_length
    min = self.event_type.minimum_abstract_length

    if len < min
      errors.add(:abstract, "cannot have less than #{min} words")
    end

    if len > max
      errors.add(:abstract, "cannot have more than #{max} words")
    end
  end

  def biography_exists
    if self.submitter.biography_word_count == 0
      errors.add(:person_biography, "must be filled out")
    end
  end

  def generate_guid
    begin
      guid = SecureRandom.urlsafe_base64
    end while self.class.where(:guid => guid).exists?
    self.guid = guid
  end

end
