class Room < ActiveRecord::Base
  attr_accessible :name, :size, :public, :conference_id

  belongs_to :conference
  has_many :events

  before_create :generate_guid

  validates :name, presence: true

  validates :size, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  validates :size, presence: true, if: :public?

  private

  def generate_guid
    guid = SecureRandom.urlsafe_base64
    self.guid = guid
  end
end
