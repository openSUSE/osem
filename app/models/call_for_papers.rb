class CallForPapers < ActiveRecord::Base
  attr_accessible :start_date, :end_date, :hard_deadline, :description, :schedule_changes
  belongs_to :conference

  validates_presence_of :start_date, :end_date, :hard_deadline

end