class Person < ActiveRecord::Base
  include Gravtastic
  gravtastic :size => 32

  attr_accessible :email, :first_name, :last_name, :public_name, :biography, :company, :avatar, :irc_nickname, :mobile, :tshirt, :languages, :volunteer_experience

  belongs_to :user, :inverse_of => :person
  has_many :event_people, :dependent => :destroy
  has_many :events, -> { uniq }, :through => :event_people
  has_many :registrations, :dependent => :destroy
  has_many :votes, :dependent => :destroy
  has_many :voted_events, :through => :votes, :source => :events

  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :email, :presence => true
  validate :biography_limit

  before_create :generate_guid
  before_save :set_public_name

  has_attached_file :avatar,
                    :styles => {:tiny => "16x16>", :small => "32x32>", :large => "128x128>"},
                    :default_url => "person_:style.png"
  validates_attachment_content_type :avatar, :content_type => [/jpg/, /jpeg/, /png/, /gif/]

  alias_attribute :affiliation, :company

  def to_s
    if self.public_name.empty?
      self.first_name + " " + self.last_name
    else
      self.public_name
    end
  end

  def attending_conference? conference
    Registration.where(:conference_id => conference.id,
                       :person_id => self.id).count
  end


  def proposals conference
    events.where('conference_id = ? AND event_people.event_role=?', conference.id, 'submitter')
  end

  def proposal_count conference
    proposals(conference).count
  end

  def biography_word_count
    if self.biography.nil?
      0
    else
      self.biography.split.size
    end
  end

  def self.find_person_by_user_id user_id
    Person.where(:user_id => user_id).first
  end

  def confirmed?
    if User.exists?(self.user_id)
      user = User.find(self.user_id)
      if user.confirmed?
        true
      else
        false
      end
    else
      false
    end
  end

  private
  def biography_limit
    if !self.biography.nil? && self.biography.split.size > 150
      errors.add(:abstract, "cannot have more than 150 words")
    end
  end

  def set_public_name
    if public_name.blank?
      self.public_name = ""
      self.public_name = "#{first_name} #{last_name}" if !first_name.blank? && !last_name.blank?
    end
  end

  def generate_guid
    begin
      guid = SecureRandom.urlsafe_base64
    end while Person.where(:guid => guid).exists?
    self.guid = guid
  end

end
