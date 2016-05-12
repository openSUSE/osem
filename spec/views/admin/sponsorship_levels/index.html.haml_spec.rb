require 'spec_helper'

describe 'admin/sponsorship_levels/index' do
  it 'renders sponsorship levels' do
    @sponsorship_level = create(:sponsorship_level)
    assign :conference, @sponsorship_level.conference
    render
    expect(rendered).to include(CGI.escapeHTML(@sponsorship_level.title))
  end
end
