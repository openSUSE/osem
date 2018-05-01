# frozen_string_literal: true

module PathsHelper
  ##
  # Includes functions related to links or redirects
  ##

  def active_nav_li(link)
    if current_page?(link)
      'active'
    else
      ''
    end
  end
end
