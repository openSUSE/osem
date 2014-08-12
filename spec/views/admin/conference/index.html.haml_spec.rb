require 'spec_helper'

describe 'admin/conference/index' do
  it 'renders all conference names with links' do
    assign(:conferences, [create(:conference, title: 'openSUSE'), create(:conference)])
    render
    expect(rendered).to include('openSUSE')
    expect(rendered).to include('The dog and pony show')
  end
end
