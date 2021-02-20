# frozen_string_literal: true

# == Schema Information
#
# Table name: answers
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#
class Answer < ApplicationRecord
  has_many :qanswers
  has_many :questions, through: :qanswers

  validates :title, presence: true
end
