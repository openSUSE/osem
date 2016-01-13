class RegistrationPeriod < ActiveRecord::Base
  validates :start_date, :end_date, presence: true

  belongs_to :conference
end
