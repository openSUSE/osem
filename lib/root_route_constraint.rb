class RootRouteConstraint
  def initialize
    @current = Conference.where('end_date >= ?', Date.current).reorder(start_date: :asc)
  end

  def matches?(*)
    return unless @current.present? && @current.first.splashpage.present?
    @current.count == 1 && @current.first.splashpage.public?
  end
end
