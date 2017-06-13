class Organization < ActiveRecord::Base
  has_many :conferences, dependent: :destroy

  validates :name, presence: true

  mount_uploader :picture, PictureUploader, mount_on: :picture
end
