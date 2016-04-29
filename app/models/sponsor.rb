class Sponsor < ActiveRecord::Base
  belongs_to :sponsorship_level
  belongs_to :conference

  mount_uploader :picture, PictureUploader, mount_on: :logo_file_name

  validates_presence_of :name, :website_url, :sponsorship_level
end
