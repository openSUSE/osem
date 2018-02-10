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

  def rating_stars(rating, max, options = {})
    max.times.collect do |counter|
      content_tag(
        'label',
        '',
        class: "rating#{' bright' if rating.to_f > counter}",
        **options
      )
    end.join.html_safe
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

  def track_selector_input(form)
    if @program.tracks.confirmed.cfp_active.any?
      form.input :track_id, as: :select,
                            collection: @program.tracks.confirmed.cfp_active.pluck(:name, :id),
                            include_blank: '(Please select)'
    end
  end

  def rating_tooltip(event, max_rating)
    "#{event.average_rating}/#{max_rating}, #{pluralize(event.voters.length, 'vote')}"
  end
end
