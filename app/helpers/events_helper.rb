# frozen_string_literal: true

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
    Array.new(max) do |counter|
      content_tag(
        'label',
        '',
        class: "rating#{' bright' if rating.to_f > counter}",
        **options
      )
    end.join.html_safe
  end

  def rating_fraction(rating, max, options = {})
    content_tag('span', "#{rating}/#{max}", **options)
  end

  def replacement_event_notice(event_schedule)
    if event_schedule.present? && event_schedule.replacement?(@withdrawn_event_schedules)
      replaced_event = event_schedule.replaced_event_schedule.try(:event)
      content_tag :span do
        concat content_tag :span, 'Please note that this talk replaces '
        concat link_to replaced_event.title, conference_program_proposal_path(@conference.short_title, replaced_event.id)
      end
    end
  end

  def canceled_replacement_event_label(event, event_schedule, *label_classes)
    if event.state == 'canceled' || event.state == 'withdrawn'
      content_tag :span, 'CANCELED', class: (['label', 'label-danger'] + label_classes)
    elsif event_schedule.present? && event_schedule.replacement?(@withdrawn_event_schedules)
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

  def event_type_dropdown(event, event_types, conference_id)
    selection = event.event_type.try(:title) || 'Event Type'
    options = event_types.collect do |event_type|
      [
        event_type.title,
        admin_conference_program_event_path(
          conference_id,
          event,
          event: { event_type_id: event_type.id }
        )
      ]
    end
    active_dropdown(selection, options)
  end

  def track_dropdown(event, tracks, conference_id)
    selection = event.track.try(:name) || 'Track'
    options = tracks.collect do |track|
      [
        track.name,
        admin_conference_program_event_path(
          conference_id,
          event,
          event: { track_id: track.id }
        )
      ]
    end
    active_dropdown(selection, options)
  end

  def difficulty_dropdown(event, difficulties, conference_id)
    selection = event.difficulty_level.try(:title) || 'Difficulty'
    options = difficulties.collect do |difficulty|
      [
        difficulty.title,
        admin_conference_program_event_path(
          conference_id,
          event,
          event: { difficulty_level_id: difficulty.id }
        )
      ]
    end
    active_dropdown(selection, options)
  end

  def state_dropdown(event, conference_id, email_settings)
    selection = event.state.humanize
    options = []
    if event.transition_possible? :accept
      options << [
        'Accept',
        accept_admin_conference_program_event_path(conference_id, event)
      ]
      if email_settings.send_on_accepted?
        options << [
          'Accept (without email)',
          accept_admin_conference_program_event_path(
            conference_id,
            event,
            send_mail: false
          )
        ]
      end
    end
    if event.transition_possible? :reject
      options << [
        'Reject',
        reject_admin_conference_program_event_path(conference_id, event)
      ]
      if email_settings.send_on_rejected?
        options << [
          'Reject (without email)',
          reject_admin_conference_program_event_path(
            conference_id,
            event,
            send_mail: false
          )
        ]
      end
    end
    if event.transition_possible? :restart
      options << [
        'Start review',
        restart_admin_conference_program_event_path(conference_id, event)
      ]
    end
    if event.transition_possible? :confirm
      options << [
        'Confirm',
        confirm_admin_conference_program_event_path(conference_id, event)
      ]
    end
    if event.transition_possible? :cancel
      options << [
        'Cancel',
        cancel_admin_conference_program_event_path(conference_id, event)
      ]
    end
    active_dropdown(selection, options)
  end

  def event_switch_checkbox(event, attribute, conference_id)
    check_box_tag(
      conference_id,
      event.id,
      event.send(attribute),
      url:    admin_conference_program_event_path(
        conference_id,
        event,
        event: { attribute => nil }
      ),
      class:  'switch-checkbox'
    )
  end

  private

  def active_dropdown(selection, options)
    # Consistent rendering of dropdown lists that submit patched changes
    #
    # Selection is the string to show by default, which is clicked to expose the
    # dropdown options.
    # Options is a list of 2-item lists; for each entry:
    # * [0] is the text of the option,
    # * [1] is the link url for the options
    content_tag('div', class: 'dropdown') do
      content_tag(
        'a',
        class: 'dropdown-toggle',
        href:  '#',
        data:  { toggle: 'dropdown' }
      ) do
        content_tag('span', selection) +
          content_tag('span', '', class: 'caret')
      end +
        content_tag('ul', class: 'dropdown-menu') do
          options.collect do |option|
            content_tag('li', link_to(option[0], option[1], method: :patch))
          end.join.html_safe
        end
    end
  end
end
