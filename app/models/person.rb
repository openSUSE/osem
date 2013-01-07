class Person < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name, :public_name, :biography, :company

  has_many :event_people, :dependent => :destroy
  has_many :events, :through => :event_people, :uniq => true
  has_many :registrations, :dependent => :destroy
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validate :biography_limit

  before_create :generate_guid
  before_save :set_public_name

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
    self.events.where("conference_id = ? AND state != ? AND state != ?", conference.id, "withdrawn", "rejected")
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

  private
  def biography_limit
    if self.biography.split.size > 150
      errors.add(:abstract, "cannot have more than 150 words")
    end
  end

  def set_public_name
    if public_name.empty?
      self.public_name = "#{first_name} #{last_name}"
    end
  end

  def generate_guid
    begin
      guid = SecureRandom.urlsafe_base64
    end while Person.where(:guid => guid).exists?
    self.guid = guid
  end

end