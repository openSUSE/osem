# frozen_string_literal: true

# == Schema Information
#
# Table name: questions
#
#  id               :bigint           not null, primary key
#  global           :boolean
#  title            :string
#  created_at       :datetime
#  updated_at       :datetime
#  conference_id    :integer
#  question_type_id :integer
#
class Question < ApplicationRecord
  belongs_to :question_type
  has_and_belongs_to_many :conferences

  has_many :qanswers, dependent: :delete_all
  has_many :answers, through: :qanswers, dependent: :delete_all

  validates :title, :question_type_id, presence: true
  validate :existing_answers
  accepts_nested_attributes_for :answers, allow_destroy: true

  private

  def existing_answers
    errors.add(:base, 'Must have answers') if answers.blank?
  end
end
