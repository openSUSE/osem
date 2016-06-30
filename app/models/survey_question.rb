class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey

  # Order of this list should not be changed without proper action!
  enum kind: [:boolean, :choice, :string, :text, :datetime, :numeric]

  ICONS = { boolean: 'dot-circle-o', choice: 'check-square-o', string: 'edit', text: 'align-left', datetime: 'clock-o', numeric: 'slack' }

  validates :title, presence: true
  validates :possible_answers, :max_choices, :min_choices, presence: true, if: "choice?"
  validates :min_choices, numericality: { greater_than_or_equal_to: 1 }, allow_blank: true
  validates :max_choices, numericality: { greater_than_or_equal_to: 1 }, allow_blank: true

  validate :max_choices_greater_than_min
  has_many :survey_replies


  def single_choice?
    choice? && max_choices == 1 && min_choices == 1
  end

  def multiple_choice?
    choice? && max_choices > 1
  end

  def possible_answers=(value)
    write_attribute(:possible_answers, choice? ? value : nil)
  end

  def min_choices=(value)
    write_attribute(:min_choices, choice? ? value : nil)
  end

  def max_choices=(value)
    write_attribute(:max_choices, choice? ? value : nil)
  end

  private

  def max_choices_greater_than_min
    errors.add(:max_choices, "Max choices should not be less than min choices") if choice? && max_choices.to_i < min_choices.to_i
  end
end
