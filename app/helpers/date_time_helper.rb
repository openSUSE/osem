# frozen_string_literal: true

module DateTimeHelper
  ##
  # Includes functions related to date or time manipulations
  ##
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
