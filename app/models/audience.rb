class Audience < ActiveRecord::Base
  attr_accessible :registration_description, :registration_start_date, :registration_end_date

  belongs_to :conference
end
