module Sidebar
  def sidebar
    @conference = create(:conference)
    assign :conference, @conference
    render
    expect(view).to render_template('admin/conference/_sidebar')
  end
end
