class CallForPapers < ActiveRecord::Base
  attr_accessible :start_date, :end_date, :hard_deadline, :description, :schedule_changes, :rating, :rating_desc
  belongs_to :conference

  validates_presence_of :start_date, :end_date, :hard_deadline
  validates :rating, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10 }

end
