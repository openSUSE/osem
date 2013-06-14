class Person < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name, :public_name, :biography, :company, :avatar, :irc_nickname

  has_many :event_people, :dependent => :destroy
  has_many :events, :through => :event_people, :uniq => true
  has_many :registrations, :dependent => :destroy

  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validate :biography_limit

  before_create :generate_guid
  before_save :set_public_name

  has_attached_file :avatar,
                    :styles => {:tiny => "16x16>", :small => "32x32>", :large => "128x128>"},
                    :default_url => "person_:style.png"
  validates_attachment_content_type :avatar, :content_type => [/jpg/, /jpeg/, /png/, /gif/]
  def to_s
    if self.public_name.empty?
      self.first_name + " " + self.last_name
    else
      self.public_name
    end
  end

  def withdraw_proposal id
    proposal = self.events.find_by_id(id)
    if !proposal.nil?
      proposal.withdraw
      proposal.save
    end
  end

  def attending_conference? conference
    Registration.where(:conference_id => conference.id,
                       :person_id => self.id).count
  end


  def proposals conference
    self.events.where("conference_id = ? AND state != ? AND state != ? AND event_people.event_role=?", conference.id, "withdrawn", "rejected", "submitter")
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

end
