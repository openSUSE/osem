class Track < ActiveRecord::Base
  include RevisionCount

  resourcify :roles, dependent: :delete_all

  belongs_to :program
  belongs_to :submitter, class_name: 'User'
  has_many :events, dependent: :nullify

  has_paper_trail only: [:name, :description, :color], meta: { conference_id: :conference_id }

  before_create :generate_guid
  validates :name, presence: true
  validates :color, format: /\A#[0-9A-F]{6}\z/
  validates :short_name,
            presence: true,
            format: /\A[a-zA-Z0-9_-]*\z/,
            uniqueness: {
              scope: :program
            }
  validates :state, presence: true, if: :self_organized?
  validates :cfp_active, inclusion: { in: [true, false] }, if: :self_organized?

  before_validation :capitalize_color

  after_create :create_organizer_role, if: :self_organized?

  def conference
    program.conference
  end

  ##
  # Checks if the track is self-organized
  # ====Returns
  # * +true+ -> If the track has a submitter
  # * +false+ -> if the track doesn't have a submitter
  def self_organized?
    return true if submitter
    false
  end

  private

  def generate_guid
    guid = SecureRandom.urlsafe_base64
#     begin
#       guid = SecureRandom.urlsafe_base64
#     end while Person.where(:guid => guid).exists?
    self.guid = guid
  end

  def capitalize_color
    self.color = color.upcase if color.present?
  end

  def conference_id
    program.conference_id
  end

  ##
  # Creates the role of the track organizer
  def create_organizer_role
    Role.where(name: 'track_organizer', resource: self).first_or_create(description: 'For the organizers of the Track')
  end
end
