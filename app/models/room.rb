class Room < ActiveRecord::Base
  belongs_to :program
  has_many :events, dependent: :nullify

  before_create :generate_guid

  validates :name, presence: true

  validates :size, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  private

  def generate_guid
    guid = SecureRandom.urlsafe_base64
    self.guid = guid
  end
end
