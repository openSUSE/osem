class Room < ActiveRecord::Base
  attr_accessible :name, :size, :public

  belongs_to :conference
  has_many :events

  before_create :generate_guid

  private

  def generate_guid
    guid = SecureRandom.urlsafe_base64
#     begin
#       guid = SecureRandom.urlsafe_base64
#     end while Person.where(:guid => guid).exists?
    self.guid = guid
  end

end