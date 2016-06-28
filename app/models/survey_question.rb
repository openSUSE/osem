class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey

  # Order of this list should not be changed without proper action!
  enum type: [:boolean, :choice, :string, :text, :datetime, :numeric]

  ICONS = { boolean: 'dot-circle-o', choice: 'check-square-o', string: 'edit', text: 'align-left', datetime: 'clock-o', numeric: 'slack' }

  validates :title, presence: true
end
