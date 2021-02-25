# frozen_string_literal: true

# == Schema Information
#
# Table name: sponsorship_levels
#
#  id            :bigint           not null, primary key
#  position      :integer
#  title         :string
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#
class SponsorshipLevel < ApplicationRecord
  validates :title, presence: true
  belongs_to :conference
  acts_as_list scope: :conference
  has_many :sponsors

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }
end
