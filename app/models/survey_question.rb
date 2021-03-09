# frozen_string_literal: true

# == Schema Information
#
# Table name: survey_questions
#
#  id               :bigint           not null, primary key
#  kind             :integer          default("boolean")
#  mandatory        :boolean          default(FALSE)
#  max_choices      :integer
#  min_choices      :integer
#  possible_answers :text
#  title            :string
#  survey_id        :integer
#
class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_replies, dependent: :destroy

  # Order of this list should not be changed without proper action!
  enum kind: [:boolean, :choice, :string, :text, :datetime, :numeric]

  ICONS = { boolean: 'dot-circle-o', choice: 'check-square-o', string: 'edit', text: 'align-left', datetime: 'clock-o', numeric: 'slack' }.freeze

  validates :title, presence: true
  validates :possible_answers, :max_choices, :min_choices, presence: true, if: :choice?
  validates :min_choices, numericality: { greater_than_or_equal_to: 1 }, allow_blank: true, if: :choice?
  validates :max_choices, numericality: { greater_than_or_equal_to: 1 }, allow_blank: true, if: :choice?

  validate :max_choices_greater_than_min

  def single_choice?
    choice? && max_choices == 1 && min_choices == 1
  end

  def multiple_choice?
    choice? && max_choices > 1
  end

  def possible_answers=(value)
    self[:possible_answers] = value if choice?
  end

  def min_choices=(value)
    self[:min_choices] = value if choice?
  end

  def max_choices=(value)
    self[:max_choices] = value if choice?
  end

  private

  def max_choices_greater_than_min
    errors.add(:max_choices, 'Max choices should not be less than min choices') if choice? && max_choices.to_i < min_choices.to_i
  end
end
