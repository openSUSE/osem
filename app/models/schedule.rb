class Schedule < ActiveRecord::Base
  belongs_to :program
  has_many :event_schedules, dependent: :destroy
  has_many :events, through: :event_schedules

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  START_HOUR = (ENV['OSEM_SCHEDULE_START_HOUR']).nil? ? 9 : ENV['OSEM_SCHEDULE_START_HOUR'].to_i
  END_HOUR = (ENV['OSEM_SCHEDULE_END_HOUR']).nil? ? 18 : ENV['OSEM_SCHEDULE_END_HOUR'].to_i

  private

  def conference_id
    program.conference_id
  end
end
