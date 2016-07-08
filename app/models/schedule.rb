class Schedule < ActiveRecord::Base
  belongs_to :program
  has_many :event_schedules, dependent: :destroy
end
