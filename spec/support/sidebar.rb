module Sidebar
  def sidebar
    @conference = create(:conference)
    assign :conference, @conference
    assign :cfp, CallForPapers.new
    render 
    expect(view).to render_template('admin/conference/_sidebar')
  end
end