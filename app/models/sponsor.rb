# frozen_string_literal: true

class Sponsor < ApplicationRecord
  belongs_to :sponsorship_level
  belongs_to :conference

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  mount_uploader :picture, PictureUploader, mount_on: :logo_file_name

  validates :name, :website_url, :sponsorship_level, presence: true
end
