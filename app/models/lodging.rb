# frozen_string_literal: true

class Lodging < ApplicationRecord
  belongs_to :conference

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  validates :name, presence: true

  mount_uploader :picture, PictureUploader, mount_on: :photo_file_name
end
