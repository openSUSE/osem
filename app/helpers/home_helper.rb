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
  def conference_date_string(start_date, end_date)
    startstr = 'Unknown - '
    endstr = 'Unknown'
    # When the conference  in the same motn
    if start_date.month == end_date.month && start_date.year == end_date.year
      startstr = start_date.strftime('%B %d - ')
      endstr = end_date.strftime('%d, %Y')
    elsif start_date.month != end_date.month && start_date.year == end_date.year
      startstr = start_date.strftime('%B %d - ')
      endstr = end_date.strftime('%B %d, %Y')
    else
      startstr = start_date.strftime('%B %d, %Y - ')
      endstr = end_date.strftime('%B %d, %Y')
    end

    result = startstr + endstr
    result
  end

end
