# derived from http://railscasts.com/episodes/340-datatables
# handles server side multi-column searching and sorting

class Datatable
  delegate :params, :h, :raw, :link_to, :number_to_currency, to: :@view

  def initialize(klass, view)
    @klass = klass
    @view = view
  end

  def as_json
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: @klass.count,
        iTotalDisplayRecords: items.total_entries,
        aaData: data
    }
  end

  def data
    []
  end

  def columns
    []
  end

  private

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = filtered_list
    items = selected_columns(items)
    items = items.order(sort_order)
    items = items.page(page).per_page(per_page)
    if params[:sSearch].present?
      items = items.where(quick_search)
    end
    items
  end

  def filtered_list
    @klass.scoped
  end

  def selected_columns items
    items
  end

  def quick_search
    search_for = params[:sSearch].split(' ')
    terms = {}
    which_one = -1
    criteria = search_for.inject([]) do |mem, atom|
      which_one += 1
      terms["search#{which_one}".to_sym] = "%#{atom}%"
      mem << "(#{search_cols.map{|col| "#{col} like :search#{which_one}"}.join(' or ')})"
    end.join(' and ')
    [criteria, terms]
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_order
    colnum = 0
    sort_by = []
    while true
      break if !sorted?(colnum)
      sort_by << "#{sort_column(colnum)} #{sort_direction(colnum)}"
      colnum += 1
    end
    sort_by.join(', ')
  end

  def sorted? index=0
    !params["iSortCol_#{index}"].nil?
  end

  def sort_column index=0
    index = "iSortCol_#{index}"
    columns[params[index].to_i]
  end

  def sort_direction index=0
    index = "sSortDir_#{index}"
    params[index] == 'desc' ? 'desc' : 'asc'
  end
end
