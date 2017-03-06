module ApplicationHelper
  # Including custom made helpers
  include DateTimeHelper
  include FormatHelper
  include EventsHelper
  include UsersHelper
  include PathsHelper
  include ChangeDescriptionHelper
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

  # Set resource_name for devise so that we can call the devise help links (views/devise/shared/_links) from anywhere (eg sign_up form in proposals#new)
  def resource_name
    :user
  end

  def add_association_link(association_name, form_builder, div_class, html_options = {})
    link_to_add_association 'Add ' + association_name.to_s.singularize, form_builder, div_class, html_options.merge(class: 'assoc btn btn-success')
  end

  def remove_association_link(association_name, form_builder)
    link_to_remove_association('Remove ' + association_name.to_s.singularize, form_builder, class: 'assoc btn btn-danger') + tag(:hr)
  end

  def dynamic_association(association_name, title, form_builder, options = {})
    render 'shared/dynamic_association', association_name: association_name, title: title, f: form_builder, hint: options[:hint]
  end

  def tracks(conference)
    all = conference.program.tracks.map {|t| t.name}
    first = all[0...-1]
    last = all[-1]
    ts = ''
    if all.length > 1
      ts << first.join(', ')
      ts << " and #{last}"
    else
      ts = all.join
    end
    return ts
  end

  def difficulty_levels(conference)
    all = conference.program.difficulty_levels.map {|t| t.title}
    first = all[0...-1]
    last = all[-1]
    ts = ''
    if all.length > 1
      ts << first.join(', ')
      ts << " and #{last}"
    else
      ts = all.join
    end
    return ts
  end

  def unread_notifications(user)
    Comment.accessible_by(current_ability).find_since_last_login(user)
  end

  # Recieves a PaperTrail::Version object
  # Outputs the list of attributes that were changed in the version (ignoring changes from one blank value to another)
  # Eg: If version.changeset = '{"title"=>[nil, "Premium"], "description"=>[nil, "Premium = Super cool"], "conference_id"=>[nil, 3]}'
  # Output will be 'title, description and conference'
  def updated_attributes(version)
    version.changeset
      .reject{ |_, values| values[0].blank? && values[1].blank? }
      .keys.map{ |key| key.gsub('_id', '').tr('_', ' ')}.join(', ')
      .reverse.sub(',', ' dna ').reverse
  end

  # Recieves a model_name and id
  # Returns nil if model_name is invalid
  # Returns object in its current state if its alive
  # Otherwise Returns object state just before deletion
  def current_or_last_object_state(model_name, id)
    return nil unless id.present? && model_name.present?
    begin
      object = model_name.constantize.find_by(id: id)
    rescue NameError
      return nil
    end

    if object.nil?
      object_last_version = PaperTrail::Version.where(item_type: model_name, item_id: id).last
      object = object_last_version.reify if object_last_version
    end
    object
  end

  # Same as redirect_to(:back) if there is a valid HTTP referer, otherwise redirect_to()
  def redirect_back_or_to(options = {}, response_status = {})
    if request.env['HTTP_REFERER']
      redirect_to :back
    else
      redirect_to options, response_status
    end
  end

  def concurrent_events(event)
    return nil unless event.scheduled? && event.program.selected_event_schedules
    event_schedule = event.program.selected_event_schedules.find_by(event: event)
    other_event_schedules = event.program.selected_event_schedules.reject { |other_event_schedule| other_event_schedule == event_schedule }
    concurrent_events = []

    event_time_range = (event_schedule.start_time.strftime '%Y-%m-%d %H:%M')...(event_schedule.end_time.strftime '%Y-%m-%d %H:%M')
    other_event_schedules.each do |other_event_schedule|
      next unless other_event_schedule.event.confirmed?
      other_event_time_range = (other_event_schedule.start_time.strftime '%Y-%m-%d %H:%M')...(other_event_schedule.end_time.strftime '%Y-%m-%d %H:%M')
      if (event_time_range.to_a & other_event_time_range.to_a).present?
        concurrent_events << other_event_schedule.event
      end
    end
    concurrent_events
  end

  def speaker_links(event)
    event.speakers.map{ |speaker| link_to speaker.name, admin_user_path(speaker) }.join(', ').html_safe
  end

  def speaker_selector_input(form)
    users = User.active.pluck(:id, :name, :username, :email).map { |user| [user[0], user[1].blank? ? user[2] : user[1], user[2], user[3]] }.sort_by { |user| user[1].downcase }
    form.input :speakers, as: :select,
                          collection: options_for_select(users.map {|user| ["#{user[1]} (#{user[2]}) #{user[3]}", user[0]]}, @event.speakers.map(&:id)),
                          include_blank: false, label: 'Speakers', input_html: { class: 'select-help-toggle', multiple: 'true' }
  end

  def event_types(conference)
    all = conference.program.event_types.map { |et| et.title.pluralize }
    first = all[0...-1]
    last = all[-1]
    ets = ''
    if all.length > 1
      ets << first.join(', ')
      ets << " and #{last}"
    else
      ets = all.join
    end
    ets
  end

  def sign_in_path
    if ENV['OSEM_ICHAIN_ENABLED'] == 'true'
      new_user_ichain_session_path
    else
      new_user_session_path
    end
  end
end
