class Lodging < ActiveRecord::Base
  belongs_to :conference

  validates :name, presence: true

  mount_uploader :picture, PictureUploader, mount_on: :photo_file_name
end
