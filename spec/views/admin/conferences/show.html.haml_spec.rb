require 'spec_helper'

describe 'admin/conferences/show' do

  it 'renders conference dashboard' do
    conference = create(:conference, title: 'openSUSE')
    assign :conference, conference
    assign :program, conference.program
    assign :conference_progress, conference.get_status
    render template: 'admin/conferences/show.html.haml'
    expect(rendered).to include("Dashboard for #{conference.title}")
  end
end
