class Schedule < ActiveRecord::Base
  belongs_to :program
  has_many :event_schedules, dependent: :destroy
  has_many :events, through: :event_schedules
end
