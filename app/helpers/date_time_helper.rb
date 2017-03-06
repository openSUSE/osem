module DateTimeHelper
  ##
  # Includes functions related to date or time manipulations
  ##
  ##
  # Returns a string build from the start and end date of the given conference.
  #
  # If the conference is only one day long
  # * %B %d %Y (January 17 2014)
  # If the conference starts and ends in the same month and year
  # * %B %d - %d, %Y (January 17 - 21 2014)
  # If the conference ends in another month but in the same year
  # * %B %d - %B %d, %Y (January 31 - February 02 2014)
  # All other cases
  # * %B %d, %Y - %B %d, %Y (December 30, 2013 - January 02, 2014)
  def date_string(start_date, end_date)
    startstr = 'Unknown - '
    endstr = 'Unknown'
    # When the conference is in the same month
    if start_date.month == end_date.month && start_date.year == end_date.year
      if start_date.day == end_date.day
        startstr = start_date.strftime('%B %d')
        endstr = end_date.strftime(' %Y')
      else
        startstr = start_date.strftime('%B %d - ')
        endstr = end_date.strftime('%d, %Y')
      end
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

  ##
  # Gets an EventType object, and returns its length in timestamp format (HH:MM)
  # ====Gets
  # * +Integer+ -> 30
  # ====Returns
  # * +String+ -> "00:30"
  def length_timestamp(length)
    [length / 60, length % 60].map { |t| t.to_s.rjust(2, '0') }.join(':')
  end

  ##
  # Gets a datetime object
  # ====Returns
  # * +String+ -> formated datetime object
  def format_datetime(obj)
    return unless obj
    obj.strftime('%Y-%m-%d %H:%M')
  end

  def show_time(length)
    return '0 h 0 min' if length.blank?

    h, min = length.divmod(60)

    if h == 0
      "#{min.round} min"
    elsif min == 0
      "#{h} h"
    else
      "#{h} h #{min.round} min"
    end
  end
end
