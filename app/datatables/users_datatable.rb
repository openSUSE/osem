class UsersDatatable
  delegate :params, :link_to, :current_ability, :show_roles, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(_options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: User.count,
      iTotalDisplayRecords: users.count,
      aaData: data
    }
  end

  private

  def data
    paginate(users).map do |user|
      [
        user.id,
        (user.confirmed? ? 'confirmed' : 'unconfirmed'),
        user.email,
        user.name,
        user.registrations.where(attended: true).count,
        (user.roles.empty? ? 'None' : "#{show_roles(user.get_roles.first(2))} #{'...' if user.get_roles.count > 2}"),
        (link_to('View', Rails.application.routes.url_helpers.admin_user_path(user), class: 'btn btn-success') if current_ability.can?(:show, user)),
        (link_to('Edit', Rails.application.routes.url_helpers.edit_admin_user_path(user), class: 'btn btn-primary') if current_ability.can?(:update, user))
      ]
    end
  end

  def users
    @users ||= fetch_users
  end

  def fetch_users
    sort_direction = params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
    sort_column = %w(id state email name)[params[:iSortCol_0].to_i]
    users = User.order("#{sort_column} #{sort_direction}")
    if params[:sSearch].present?
      users = users.where('name like :search or email like :search', search: "%#{params[:sSearch]}%")
    end
    users
  end

  def paginate(users)
    per_page = params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    page = params[:iDisplayStart].to_i / per_page + 1
    users.offset((page - 1) * per_page).limit(per_page)
  end
end
