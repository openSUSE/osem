# frozen_string_literal: true

# == Schema Information
#
# Table name: vdays
#
#  id            :bigint           not null, primary key
#  day           :date
#  description   :text
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#
class Vday < ApplicationRecord
  belongs_to :conference

  has_many :vchoices
  has_many :vpositions, through: :vchoices, dependent: :destroy
end
