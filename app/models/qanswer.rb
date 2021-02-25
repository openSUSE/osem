# frozen_string_literal: true

# == Schema Information
#
# Table name: qanswers
#
#  id          :bigint           not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  answer_id   :integer
#  question_id :integer
#
class Qanswer < ApplicationRecord
  belongs_to :question
  belongs_to :answer, dependent: :delete

  has_and_belongs_to_many :registrations

  validates :question, :answer, presence: true
end
