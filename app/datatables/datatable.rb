class Datatable
  delegate :params, to: :@view

  def initialize(view, collection, search_columns, sort_columns)
    @view = view
    @collection = collection
    @search_columns = search_columns
    @sort_columns = sort_columns
  end

  def as_json(options={})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: @collection.count,
      iTotalDisplayRecords: records.count,
      aaData: options[:data]
    }
  end

  def paginated_records
    paginate(records)
  end

  private

  def records
    @records ||= fetch_records
  end

  def fetch_records
    sort_direction = params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
    sort_column = @sort_columns[params[:iSortCol_0].to_i]
    records = @collection.order("#{sort_column} #{sort_direction}")
    if params[:sSearch].present? && @search_columns.present?
      search_query = ''
      @search_columns.each { |column| search_query += "#{column} like :search or " }
      search_query = search_query.chomp(' or ')
      records = records.where(search_query, search: "%#{params[:sSearch]}%")
    end
    records
  end

  def paginate(records)
    per_page = params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    page = params[:iDisplayStart].to_i / per_page + 1
    records.offset((page - 1) * per_page).limit(per_page)
  end
end
