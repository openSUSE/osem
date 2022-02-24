# frozen_string_literal: true

module EventTypesHelper
  ##
  # Includes functions related to event_types
  ##
  ##
  # ====Returns
  # * +String+ -> number of registrations / max allowed registrations
  def event_type_select_options(event_types = {})
    event_types.map { |type| ["#{type.title} - #{show_time(type.length)}", type.id] }
  end
end
