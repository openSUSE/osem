require 'spec_helper'

describe 'admin/difficulty_levels/index' do

  it 'renders difficulty levels' do
    conference = create(:conference)
    @difficulty_level = create(:difficulty_level, program: conference.program)
    assign :conference, conference
    render
    expect(rendered).to include('Example Difficulty Level')
    expect(rendered).to include('Lorem Ipsum dolsum')
    expect(rendered).to include('#FFFFFF')
  end
end
