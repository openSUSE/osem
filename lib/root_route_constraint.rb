class RootRouteConstraint
  def initialize
    @current = Conference.where('start_date <= ? AND end_date >= ?', Date.current, Date.current).reorder(start_date: :asc)
  end

  ##
  # Checks if only one conference is live and has a public splashpage
  # If any conference is live it checks how many live conferences are there
  # ====Returns
  # * +true+ -> only one conferene is live AND the conference has public splashpage
  # * +false+ -> no or more than one conferences are live or the only live conferece has no public splashpage
  def matches?(*)
    if @current.present? && @current.first.splashpage.present?
      @current.count == 1 && @current.first.splashpage.public?
    else
      false
    end
  end
end
