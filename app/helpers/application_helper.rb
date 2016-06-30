module ApplicationHelper
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
    h = length / 60
    min = length - h * 60

    if h != 0
      if min != 0
      "#{h} h #{min} min"
      else
        "#{h} h"
      end
    else
      "#{min} min"
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
end
