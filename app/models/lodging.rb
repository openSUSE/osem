# frozen_string_literal: true

# == Schema Information
#
# Table name: lodgings
#
#  id                 :bigint           not null, primary key
#  description        :text
#  name               :string
#  photo_content_type :string
#  photo_file_name    :string
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#  picture            :string
#  website_link       :string
#  created_at         :datetime
#  updated_at         :datetime
#  conference_id      :integer
#
class Lodging < ApplicationRecord
  belongs_to :conference

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  validates :name, presence: true

  mount_uploader :picture, PictureUploader, mount_on: :photo_file_name
end
