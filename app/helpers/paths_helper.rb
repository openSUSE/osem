module PathsHelper
  ##
  # Includes functions related to links or redirects
  ##
  def link_if_alive(version, link_text, link_url)
    version.item ? link_to(link_text, link_url) : link_text
  end

  def link_to_user(user_id)
    user = User.find_by(id: user_id)
    if user
      link_to user.name, admin_user_path(id: user_id)
    else
      'Someone (probably via the console)'
    end
  end

  def sign_in_path
    if ENV['OSEM_ICHAIN_ENABLED'] == 'true'
      new_user_ichain_session_path
    else
      new_user_session_path
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
