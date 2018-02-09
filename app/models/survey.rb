# frozen_string_literal: true

class Survey < ActiveRecord::Base
  belongs_to :surveyable, polymorphic: true
  has_many :survey_questions, dependent: :destroy
  has_many :survey_submissions, dependent: :destroy

  enum target: [:after_conference, :during_registration]
  validates :title, presence: true

  def active?
    return false unless start_date && end_date
    now = Time.now.in_time_zone(surveyable.timezone)
    now >= start_date && now <= end_date
  end
end
