# frozen_string_literal: true

module Sidebar
  def sidebar
    @conference = create(:conference)
    assign :conference, @conference
    render
    expect(view).to render_template('admin/conferences/_sidebar')
  end
end
