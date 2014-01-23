module ApplicationHelper
  def getdatetime(registration, field)
    if registration.send(field.to_sym).kind_of?(String)
      DateTime.parse(registration.send(field.to_sym)).strftime("%d %b %H:%M") if registration.send(field.to_sym)
    else
      registration.send(field.to_sym).strftime("%d %b %H:%M") if registration.send(field.to_sym)
    end
  end
  
  def getdate(var)
    if var.kind_of?(String)
      DateTime.parse(var).strftime("%a, %d %b")
    else
      var.strftime("%a, %d %b")
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

  def pre_registered(event)
    @conference.events.joins(:registrations).where("events.id = ?", event.id)
  end

  def add_association_link(association_name, form_builder, div_class, html_options = {})
    link_to_add_association "Add " + association_name.to_s.singularize, form_builder, div_class, html_options.merge(:class => "assoc btn btn-success")
  end

  def remove_association_link(association_name, form_builder)
    link_to_remove_association("Remove " + association_name.to_s.singularize, form_builder, :class => "assoc btn btn-danger") + tag(:hr)
  end

  def dynamic_association(association_name, title, form_builder, options = {})
    render "shared/dynamic_association", :association_name => association_name, :title => title, :f => form_builder, :hint => options[:hint]
  end

  def has_role?(current_user, role)
    if current_user.nil?
      return false
    end

    return !!current_user.role?(role.to_s.camelize)
  end

  # Same as redirect_to(:back) if there is a valid HTTP referer, otherwise redirect_to()
  def redirect_back_or_to(options = {}, response_status = {})
    if request.env["HTTP_REFERER"]
      redirect_to(:back)
    else
      redirect_to(options, response_status)
    end
  end

  # TODO Output better html
  def format_comments(comment, padding = 0)
    result = ""
    result += "<div style='padding-left:#{padding}px'>"
    result += "<div class='well'>"
    result += "<b>#{comment.user.person.public_name}</b> <i>#{comment.created_at}</i><br><br>"
    result += comment.body
    result += "<br><div><a href='#' class='pull-right comment-reply-link'>Reply</a><br><br>"
    result += "<div class='comment-reply'>"
    result += "<form method='post' action='#{comment_admin_conference_event_path(@conference.short_title, comment.commentable_id)}'>"
    result += "<input type=hidden name=parent value='#{comment.id}'/>"
    result += "<input name='authenticity_token' type='hidden' value='#{form_authenticity_token}' />"
    result += "<textarea name='comment'></textarea>"
    result += "<button class='btn btn-primary pull-right' name='button' type='submit'>Add Reply</button>"
    result += "</form></div></div>"
    result += "</div>"
    #result += edit_admin_conference_event_path(@conference.short_title, @event)
    comment.children.each do |child|
      result += format_comments(child, 50)
      result += "</div>"
    end

    result
  end
end
