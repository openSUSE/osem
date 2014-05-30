class CallForPapers < ActiveRecord::Base
  attr_accessible :start_date, :end_date, :hard_deadline,
                  :description, :schedule_changes, :rating,
                  :schedule_public
  belongs_to :conference

  validates_presence_of :start_date, :end_date, :hard_deadline
  validates :rating, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10 }

  def self.max_weeks
    all = CallForPapers.all
    result = [0]
    all.each do |cfp|
      result.push(cfp.end_week - cfp.start_week)
    end
    result.max
  end

  def start_week
    start_date.strftime('%W').to_i
  end

  def end_week
    end_date.strftime('%W').to_i
  end
end
