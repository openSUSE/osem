# frozen_string_literal: true

# == Schema Information
#
# Table name: sponsors
#
#  id                   :bigint           not null, primary key
#  description          :text
#  logo_file_name       :string
#  name                 :string
#  picture              :string
#  website_url          :string
#  created_at           :datetime
#  updated_at           :datetime
#  conference_id        :integer
#  sponsorship_level_id :integer
#
class Sponsor < ApplicationRecord
  belongs_to :sponsorship_level
  belongs_to :conference

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  mount_uploader :picture, PictureUploader, mount_on: :logo_file_name

  validates :name, :website_url, :sponsorship_level, presence: true
end
