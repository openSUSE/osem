class Schedule < ActiveRecord::Base
  belongs_to :program
  has_many :event_schedules, dependent: :destroy
  has_many :events, through: :event_schedules

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  private

  def conference_id
    program.conference_id
  end
end
