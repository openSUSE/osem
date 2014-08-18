class RegistrationPeriod < ActiveRecord::Base
  attr_accessible :description, :start_date, :end_date

  validates :start_date, :end_date, presence: true

  belongs_to :conference
end
