module PathsHelper
  ##
  # Includes functions related to links or redirects
  ##

  def active_nav_li(link)
    if current_page?(link)
      return 'active'
    else
      return ''
    end
  end
end
