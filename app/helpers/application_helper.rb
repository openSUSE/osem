module ApplicationHelper

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
    return !!current_user.role?(role.to_s.camelize)
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
