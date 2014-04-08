##
# This class contains helper for the home views.

module HomeHelper

  ##
  # Returns a string build from the start and end date of the given conference.
  #
  # If the conference starts and ends in the same month and year
  # * %B %d - %d, %Y (January 17 - 21 2014)
  # If the conference ends in another month but in the same year
  # * %B %d - %B %d, %Y (January 31 - February 02 2014)
  # All other cases
  # * %B %d, %Y - %B %d, %Y (December 30, 2013 - January 02, 2014)
  def conference_date_string(conf)
    startstr = "Unknown - "
    endstr = "Unknown"
    # When the conference  in the same motn
    if conf.start_date.month == conf.end_date.month and conf.start_date.year == conf.end_date.year
      startstr = conf.start_date.strftime("%B %d - ")
      endstr = conf.end_date.strftime("%d, %Y")
    elsif conf.start_date.month != conf.end_date.month && conf.start_date.year == conf.end_date.year
      startstr = conf.start_date.strftime("%B %d - ")
      endstr = conf.end_date.strftime("%B %d, %Y")
    else
      startstr = conf.start_date.strftime("%B %d, %Y - ")
      endstr = conf.end_date.strftime("%B %d, %Y")
    end

    result = startstr + endstr
    result
  end

end
