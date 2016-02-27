require 'spec_helper'

describe 'admin/conference/show' do

  it 'renders conference dashboard' do
    conference = create(:conference, title: 'openSUSE')
    assign :conference, conference
    assign :program, conference.program
    assign :conference_progress, conference.get_status
    render
    expect(rendered).to include("Dashboard for #{conference.title}")
  end
end
