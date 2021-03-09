# frozen_string_literal: true

class UserDatatable < AjaxDatatablesRails::Base
  def_delegator :@view, :show_roles
  def_delegator :@view, :admin_user_path
  def_delegator :@view, :edit_admin_user_path

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id:           { source: 'User.id', cond: :eq },
      confirmed_at: { source: 'User.confirmed_at', searchable: false },
      email:        { source: 'User.email' },
      name:         { source: 'User.name' },
      username:     { source: 'User.username' },
      attended:     { source: 'attended_count', searchable: false },
      roles:        { source: 'Role.name' },
      view_url:     { source: 'User.id', searchable: false, orderable: false },
      edit_url:     { source: 'User.id', searchable: false, orderable: false }
    }
  end

  private

  def data
    records.map do |record|
      {
        id:           record.id,
        confirmed_at: record.confirmed_at,
        email:        record.email,
        name:         record.name,
        username:     record.username,
        attended:     record.attended_count,
        roles:        record.roles.any? ? show_roles(record.get_roles) : 'None',
        view_url:     admin_user_path(record),
        edit_url:     edit_admin_user_path(record),
        DT_RowId:     record.id,
        confirmed:    record.confirmed_at.present?
      }
    end
  end

  # rubocop:disable Naming/AccessorMethodName
  def get_raw_records
    User.left_outer_joins(:registrations, :roles)
      .distinct
      .select("users.*, COUNT(CASE WHEN registrations.attended = 't' THEN 1 END) AS attended_count")
      .group('users.id')
  end
  # rubocop:enable Naming/AccessorMethodName

  # Workaround for jbox-web/ajax-datatables-rails#293
  def records_total_count
    fetch_records.unscope(:group, :select).count(:all)
  end

  # Workaround for jbox-web/ajax-datatables-rails#293
  def records_filtered_count
    filter_records(fetch_records).unscope(:group, :select).count(:all)
  end

  # ==== These methods represent the basic operations to perform on records
  # and feel free to override them

  # def filter_records(records)
  # end

  # def sort_records(records)
  # end

  # def paginate_records(records)
  # end

  # ==== Insert 'presenter'-like methods below if necessary
end
