# frozen_string_literal: true

# == Schema Information
#
# Table name: booth_requests
#
#  id         :bigint           not null, primary key
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  booth_id   :integer
#  user_id    :integer
#
# Indexes
#
#  index_booth_requests_on_booth_id  (booth_id)
#  index_booth_requests_on_user_id   (user_id)
#
class BoothRequest < ApplicationRecord
  belongs_to :booth
  belongs_to :user

  validates :role,
            presence: true

  ROLES = %w[submitter responsible].freeze
end
