# frozen_string_literal: true

class Survey < ActiveRecord::Base
  belongs_to :surveyable, polymorphic: true
  has_many :survey_questions, dependent: :destroy
  has_many :survey_submissions, dependent: :destroy

  enum target: [:after_conference, :during_registration, :after_event]
  validates :title, presence: true

  ##
  # Finds active surveys
  # * if a survey has either start or end date, but not both
  # check is performed only on the attribute that exists
  # * if a survey does not have start/end dates, then it is marked active
  # further check is expected, where appropriate, depending on the survey's target
  # ====Returns
  # * +true+ -> If the survey is active (will accept replies)
  # * +false+ -> If the survey is closed
  def active?
    return true unless start_date || end_date

    # Find timezone of conference (survyeable is Conference or Event)
    timezone = surveyable.is_a?(Conference) ? surveyable.timezone : surveyable.conference.timezone
    now = Time.current.in_time_zone(timezone)

    if start_date && end_date
      now >= start_date && now <= end_date
    elsif start_date && !end_date
      now >= start_date
    elsif !start_date && end_date
      now <= end_date
    end
  end
end
