# frozen_string_literal: true

# == Schema Information
#
# Table name: vpositions
#
#  id            :bigint           not null, primary key
#  description   :text
#  title         :string           not null
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#
class Vposition < ApplicationRecord
  belongs_to :conference

  has_many :vchoices
  has_many :vdays, through: :vchoices

  validates :title, :vdays, presence: true
end
