module EventsHelper
  ##
  # Includes functions related to events
  ##
  ##
  # ====Returns
  # * +String+ -> number of registrations / max allowed registrations
  def registered_text(event)
    return "Registered: #{event.registrations.count}/#{event.max_attendees}" if event.max_attendees
    "Registered: #{event.registrations.count}"
  end

  ##
  # Checks if the voting has already started, or if it has already ended
  #
  def voting_open_or_close(program)
    return if program.voting_period?
    if program.voting_start_date > Time.current
      return 'Voting period has not started yet!'
    else # voting_end_date > Date.today because voting_start_date < voting_end_date
      return 'Voting period is over!'
    end
  end

  def replacement_event_notice(event_schedule)
    if event_schedule.present? && event_schedule.replacement?
      replaced_event = (event_schedule.intersecting_event_schedules.withdrawn.first || event_schedule.intersecting_event_schedules.canceled.first).event
      content_tag :span do
        concat content_tag :span, 'Please note that this talk replaces '
        concat link_to replaced_event.title, conference_program_proposal_path(@conference.short_title, replaced_event.id)
      end
    end
  end

  def canceled_replacement_event_label(event, event_schedule, *label_classes)
    if event.state == 'canceled' || event.state == 'withdrawn'
      content_tag :span, 'CANCELED', class: (['label', 'label-danger'] + label_classes)
    elsif event_schedule.present? && event_schedule.replacement?
      content_tag :span, 'REPLACEMENT', class: (['label', 'label-info'] + label_classes)
    end
  end
end
