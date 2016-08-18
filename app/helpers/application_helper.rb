module ApplicationHelper
  ##
  # Checks if the voting has already started, or if it has already ended
  #
  def voting_open_or_close(program)
    return if program.voting_period?
    if program.voting_start_date > Date.today
      return 'Voting period has not started yet!'
    else # voting_end_date > Date.today because voting_start_date < voting_end_date
      return 'Voting period is over!'
    end
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

  ##
  # ====Returns
  # * +String+ -> number of registrations / max allowed registrations
  def registered_text(event)
    return "Registered: #{event.registrations.count}/#{event.max_attendees}" if event.max_attendees
    "Registered: #{event.registrations.count}"
  end

  # Set resource_name for devise so that we can call the devise help links (views/devise/shared/_links) from anywhere (eg sign_up form in proposal#new)
  def resource_name
    :user
  end

  # Set devise_mapping for devise so that we can call the devise help links (views/devise/shared/_links) from anywhere (eg sign_up form in proposal#new)
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def event_status_icon(event)
    case event.state
    when 'new'
      'fa-eye'
    when 'unconfirmed'
      'fa-check text-muted'
    when 'confirmed'
      'fa-check text-success'
    when 'rejected', 'withdrawn', 'canceled'
      'fa-ban'
    end
  end

  def event_progress_color(progress)
    progress = progress.to_i
    if progress == 100
      'progress-bar-success'
    elsif progress >= 85
      'progress-bar-info'
    elsif progress >= 71
      'progress-bar-warning'
    else
      'progress-bar-danger'
    end
  end

  def target_progress_color(progress)
    progress = progress.to_i
    result =
    case
    when progress >= 90 then 'green'
    when progress < 90 && progress >= 80 then 'orange'
    else 'red'
    end

    result
  end

  def days_left_color(days_left)
    days_left = days_left.to_i
    if days_left > 30
      result = 'green'
    elsif days_left < 30 && days_left > 10
      result = 'orange'
    else
      result = 'red'
    end
    result
  end

  def bootstrap_class_for(flash_type)
    case flash_type
    when 'success'
      'alert-success'
    when 'error'
      'alert-danger'
    when 'alert'
      'alert-warning'
    when 'notice'
      'alert-info'
    else
      'alert-warning'
    end
  end

  def label_for(event_state)
    result = ''
    case event_state
    when 'new'
      result = 'label label-primary'
    when 'withdrawn'
      result = 'label label-danger'
    when 'unconfirmed'
      result = 'label label-success'
    when 'confirmed'
      result = 'label label-success'
    when 'rejected'
      result = 'label label-warning'
    when 'canceled'
      result = 'label label-danger'
    end
    result
  end

  def icon_for_todo(bool)
    if bool
      return 'fa fa-check'
    else
      return 'fa fa-times'
    end
  end

  def class_for_todo(bool)
    if bool
      return 'todolist-ok'
    else
      return 'todolist-missing'
    end
  end

  def normalize_array_length(hashmap, length)
    hashmap.each do |_, value|
      if value.length < length
        value.fill(value[-1], value.length...length)
      end
    end
  end

  def active_nav_li(link)
    if current_page?(link)
      return 'active'
    else
      return ''
    end
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

  def add_association_link(association_name, form_builder, div_class, html_options = {})
    link_to_add_association 'Add ' + association_name.to_s.singularize, form_builder, div_class, html_options.merge(class: 'assoc btn btn-success')
  end

  def remove_association_link(association_name, form_builder)
    link_to_remove_association('Remove ' + association_name.to_s.singularize, form_builder, class: 'assoc btn btn-danger') + tag(:hr)
  end

  def dynamic_association(association_name, title, form_builder, options = {})
    render 'shared/dynamic_association', association_name: association_name, title: title, f: form_builder, hint: options[:hint]
  end

  # Same as redirect_to(:back) if there is a valid HTTP referer, otherwise redirect_to()
  def redirect_back_or_to(options = {}, response_status = {})
    if request.env['HTTP_REFERER']
      redirect_to :back
    else
      redirect_to options, response_status
    end
  end

  def event_types(conference)
    all = conference.program.event_types.map { |et | et.title.pluralize }
    first = all[0...-1]
    last = all[-1]
    ets = ''
    if all.length > 1
      ets << first.join(', ')
      ets << " and #{last}"
    else
      ets = all.join
    end
    return ets
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

  # rubocop:disable Lint/EndAlignment
  def word_pluralize(count, singular, plural = nil)
    word = if (count == 1 || count =~ /^1(\.0+)?$/)
      singular
    else
      plural || singular.pluralize
    end

    "#{word}"
  end

  def markdown(text)
    return '' if text.nil?

    options = {
      autolink: true,
      space_after_headers: true,
      no_intra_emphasis: true
    }
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, options)
    markdown.render(text).html_safe
  end

  def markdown_hint(text='')
    markdown("#{text} Please look at #{link_to '**Markdown Syntax**', 'https://daringfireball.net/projects/markdown/syntax', target: '_blank'} to format your text")
  end

  def omniauth_configured
    providers = []
    Devise.omniauth_providers.each do |provider|
      provider_key = "#{provider}_key"
      provider_secret = "#{provider}_secret"
      unless Rails.application.secrets.send(provider_key).blank? || Rails.application.secrets.send(provider_secret).blank?
        providers << provider
      end
      providers << provider if !ENV["OSEM_#{provider.upcase}_KEY"].blank? && !ENV["OSEM_#{provider.upcase}_SECRET"].blank?
    end

    return providers.uniq
  end

  # Receives a hash, generated from User model, function get_roles
  # Outputs the roles of a user, including the conferences for which the user has the roles
  # Eg. organizer(oSC13, oSC14), cfp(oSC12, oSC13)
  def show_roles(roles)
    roles.map{ |x| x[0].titleize + ' (' + x[1].join(', ') + ')' }.join ', '
  end

  def can_manage_volunteers(conference)
    if (current_user.has_role? :organizer, conference) || (current_user.has_role? :volunteers_coordinator, conference)
      true
    else
      false
    end
  end

  def sign_in_path
    if ENV['OSEM_ICHAIN_ENABLED'] == 'true'
      new_user_ichain_session_path
    else
      new_user_session_path
    end
  end

  def unread_notifications(user)
    Comment.accessible_by(current_ability).find_since_last_login(user)
  end

  # Returns black or white deppending on what of them contrast more with the
  # given color. Useful to print text in a coloured background.
  # hexcolor is a hex color of 7 characters, being the first one '#'.
  # Reference: https://24ways.org/2010/calculating-color-contrast
  def contrast_color(hexcolor)
    r = hexcolor[1..2].to_i(16)
    g = hexcolor[3..4].to_i(16)
    b = hexcolor[5..6].to_i(16)
    yiq = ((r * 299) + (g * 587) + (b * 114)) / 1000
    (yiq >= 128) ? 'black' : 'white'
  end

  def td_height(rooms)
    td_height = 500 / rooms.length
    # we want all least 3 lines in events and td padding = 3px, speaker picture height >= 25px
    # and line-height = 17px => (17 * 3) + 6 + 25 = 82
    td_height < 82 ? 82 : td_height
  end

  def room_height(rooms)
    room_lines(rooms) * 17
  end

  def room_lines(rooms)
    # line-height = 17px, td padding = 3px
    (td_height(rooms) - 6) / 17
  end

  def event_height(rooms)
    event_lines(rooms) * 17
  end

  def event_lines(rooms)
    # line-height = 17px, td padding = 3px, speaker picture height >= 25px
    (td_height(rooms) - 31) / 17
  end

  def speaker_height(rooms)
    # td padding = 3px
    speaker_height = td_height(rooms) - 6 - event_height(rooms)
    # The speaker picture is a circle and the width must be <= 37 to avoid making the cell widther
    speaker_height >= 37 ? 37 : speaker_height
  end

  def speaker_width(rooms)
    # speaker picture padding: 4px 2px; and we want the picture to be a circle
    speaker_height(rooms) - 4
  end

  def carousel_item_class(number, carousel_number, num_cols, col)
    item_class = 'item'
    item_class += ' first' if number == 0
    item_class += ' last' if number == (carousel_number - 1)
    if (col && ((col / num_cols) == number)) || (!col && number == 0)
      item_class += ' active'
    end
    item_class
  end

  def selected_scheduled?(schedule)
    (schedule == @selected_schedule) ? 'Yes' : 'No'
  end

  # Recieves a PaperTrail::Version object
  # Outputs the list of attributes that were changed in the version (ignoring changes from one blank value to another)
  # Eg: If version.changeset = '{"title"=>[nil, "Premium"], "description"=>[nil, "Premium = Super cool"], "conference_id"=>[nil, 3]}'
  # Output will be 'title, description and conference'
  def updated_attributes(version)
    version.changeset.
      reject{ |_, values| values[0].blank? && values[1].blank? }.
      keys.map{ |key| key.gsub('_id', '').tr('_', ' ')}.join(', ').
      reverse.sub(',', ' dna ').reverse
  end

  def change_creator_link(user_id)
    user = User.find_by(id: user_id)
    if user
      link_to user.name, admin_user_path(id: user_id)
    else
      'Someone (probably via the console)'
    end
  end

  # Recieves a PaperTrail::Version object
  # Returns object in its current state if its alive
  # Returns object as it was before version's change(unless its a create event's version)
  # Else Returns object as it was after version's change
  def get_version_object(version)
    version.item || version.reify || version.next.reify
  end

  def event_change_description(version)
    case
    when version.event == 'create' then 'submitted new'

    when version.changeset['state']
      case version.changeset['state'][1]
      when 'unconfirmed' then 'accepted'
      when 'withdrawn' then 'withdrew'
      when 'canceled', 'rejected', 'confirmed' then version.changeset['state'][1]
      when 'new' then 'resubmitted'
      end

    when version.changeset['start_time'] && version.changeset['start_time'][0].nil?
      'scheduled'

    when version.changeset['start_time'] && version.changeset['start_time'][1].nil?
      'unscheduled'

    else
      "updated #{updated_attributes(version)} of"
    end
  end

  def users_role_change_description(version)
    version.event == 'create' ? 'added' : 'removed'
  end

  def subscription_change_description(version)
    user = get_version_object(version).user
    user_name = user.name unless user.id.to_s == version.whodunnit
    version.event == 'create' ? "subscribed #{user_name} to" : "unsubscribed #{user_name} from"
  end

  def registration_change_description(version)
    if version.item_type == 'Registration'
      user = get_version_object(version).user
    else
      registration_id = get_version_object(version).registration_id
      registration_last_version = PaperTrail::Version.where(item_type: 'Registration', item_id: registration_id).last
      user = get_version_object(registration_last_version).user
    end

    if user.id.to_s == version.whodunnit
      case version.event
      when 'create' then 'registered to'
      when 'update' then "updated #{updated_attributes(version)} of the registration for"
      when 'destroy' then 'unregistered  from'
      end
    else
      case version.event
      when 'create' then "registered #{user.name} to"
      when 'update' then "updated #{updated_attributes(version)} of  #{user.name}'s registration for"
      when 'destroy' then "unregistered #{user.name} from"
      end
    end
  end

  def comment_change_description(version)
    user = get_version_object(version).user
    if version.event == 'create'
      version.previous.nil? ? 'commented on' : "re-added #{user.name}'s comment on"
    else
      "deleted #{user.name}'s comment on"
    end
  end

  def vote_change_description(version)
    user = get_version_object(version).user
    if version.event == 'create'
      version.previous.nil? ? 'voted on' : "re-added #{user.name}'s vote on"
    elsif version.event == 'update'
      "updated #{user.name}'s vote on"
    else
      "deleted #{user.name}'s vote on"
    end
  end

  def user_change_description(version)
    if version.event == 'create'
     change_creator_link(version.item_id) + ' signed up'
    elsif version.event == 'update'
      if version.changeset.keys.include?('reset_password_sent_at')
        'Someone requested password reset of'
      elsif version.changeset.keys.include?('confirmed_at') && version.changeset['confirmed_at'][0].nil?
        (version.whodunnit.nil? ? change_creator_link(version.item_id) : change_creator_link(version.whodunnit)) + ' confirmed account of'
      elsif version.changeset.keys.include?('confirmed_at') && version.changeset['confirmed_at'][1].nil?
        change_creator_link(version.whodunnit) + ' unconfirmed account of'
      else
        change_creator_link(version.whodunnit) + " updated #{updated_attributes(version)} of"
      end
    end
  end

  def general_change_description(version)
    if version.event == 'create'
      'created new'
    elsif version.event == 'update'
      "updated #{updated_attributes(version)} of"
    else
      'deleted'
    end
  end
end
