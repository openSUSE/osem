class Track < ActiveRecord::Base
  belongs_to :program
  has_many :events, dependent: :nullify

  before_create :generate_guid
  validates :name, presence: true

  private

  def generate_guid
    guid = SecureRandom.urlsafe_base64
#     begin
#       guid = SecureRandom.urlsafe_base64
#     end while Person.where(:guid => guid).exists?
    self.guid = guid
  end
end
