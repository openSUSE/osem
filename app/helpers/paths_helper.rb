module PathsHelper
  ##
  # Includes functions related to links or redirects
  ##
  def link_to_user(user_id)
    user = User.find_by(id: user_id)
    if user
      link_to user.name, admin_user_path(id: user_id)
    else
      'Someone (probably via the console)'
    end
  end

  def active_nav_li(link)
    if current_page?(link)
      return 'active'
    else
      return ''
    end
  end
end
