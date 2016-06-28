class Survey < ActiveRecord::Base
  belongs_to :surveyable, polymorphic: true
  has_many :survey_questions
  has_many :survey_submissions

  enum target: [:after_conference, :during_registration]
  validates :title, presence: true

  def active?
    now = Time.now.in_time_zone(surveyable.timezone)
    now >= start_date && now <= end_date
  end
end
