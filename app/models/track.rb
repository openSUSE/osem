class Track < ActiveRecord::Base
  belongs_to :program
  has_many :events, dependent: :nullify

  before_create :generate_guid
  validates :name, presence: true
  validates :color, format: /\A#[0-9A-F]{6}\z/

  before_validation :capitalize_color

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
end
