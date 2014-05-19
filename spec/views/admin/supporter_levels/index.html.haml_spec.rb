require 'spec_helper'

describe 'admin/supporter_levels/index' do
  it 'renders conference sidebar' do 
    expect(sidebar).to be true
  end
  it 'renders supporter levels' do
    @support_level = create(:supporter_level)
    assign :conference, @support_level.conference
    render
    expect(rendered).to include('Example Supporter Level')
    expect(rendered).to include('www.example.com')
  end
end
