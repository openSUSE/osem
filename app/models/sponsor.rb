class Sponsor < ActiveRecord::Base
  belongs_to :sponsorship_level
  belongs_to :conference

  serialize :swag_hash, Hash
  attr_accessor :type, :quantity, :swag_index, :hint_hash

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  mount_uploader :picture, PictureUploader, mount_on: :logo_file_name

  validates :name, :website_url, :sponsorship_level, presence: true

  def generate_swags_hash(type, quantity)
    unless swag_hash
      swag_hash = {}
    end

    swag_hash[type.to_s] = quantity.to_i
    update_attribute(:swag_hash, @sponsor.swag_hash)
  end
end
