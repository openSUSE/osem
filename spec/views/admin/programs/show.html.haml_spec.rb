require 'spec_helper'

describe 'admin/programs/show' do

  it 'renders call for papers details' do
    conference = create(:conference)
    assign :conference, conference
    assign :program, conference.program
    render
    expect(rendered).to have_css('dt', text: 'Event types:')
    expect(rendered).to have_css('dd', text: 'Talks and Workshops')
    expect(rendered).to have_css('dt', text: 'Tracks:')
    expect(rendered).to have_css('dt', text: 'Difficulty Levels:')
    expect(rendered).to have_css('dd', text: 'Easy, Medium and Hard')
    expect(rendered).to have_css('dt', text: 'Languages:')
  end
end
