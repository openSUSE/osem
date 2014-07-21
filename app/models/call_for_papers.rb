class CallForPapers < ActiveRecord::Base
  attr_accessible :start_date, :end_date,
                  :description, :schedule_changes, :rating,
                  :schedule_public, :include_cfp_in_splash
  belongs_to :conference

  validates_presence_of :start_date, :end_date
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }

  ##
  # Calculates how many weeks the call for paper is.
  #
  # ====Returns
  # * +Integer+ -> start week
  def weeks
    result = end_week - start_week + 1
    weeks = Date.new(start_date.year, 12, 31).strftime('%W').to_i
    result < 0 ? result + weeks : result
  end

  ##
  # Calculates the end week of the cfp
  #
  # ====Returns
  def start_week
    start_date.strftime('%W').to_i
  end

  ##
  # Calculates the end week of the cfp
  #
  # ====Returns
  def end_week
    end_date.strftime('%W').to_i
  end
end
