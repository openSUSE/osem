class Track < ActiveRecord::Base
  attr_accessible :name, :description, :color
  validates :description, presence: true
  belongs_to :conference

  before_create :generate_guid

  private

  def generate_guid
    begin
      guid = SecureRandom.urlsafe_base64
    end while Person.where(:guid => guid).exists?
    self.guid = guid
  end

end