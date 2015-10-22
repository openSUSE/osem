require 'spec_helper'

describe 'admin/difficulty_levels/index' do
  it 'renders difficulty levels' do
    @difficulty_level = create(:difficulty_level)
    assign :conference, @difficulty_level.conference
    render
    expect(rendered).to include('Example Difficulty Level')
    expect(rendered).to include('Lorem Ipsum dolsum')
    expect(rendered).to include('#ffffff')
  end
end
