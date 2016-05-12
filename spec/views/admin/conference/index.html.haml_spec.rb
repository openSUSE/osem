require 'spec_helper'

describe 'admin/conference/index' do
  let(:conference) { create(:conference, title: 'openSUSE Conference 2016') }
  let(:second_conference) { create(:conference) }

  it 'renders all conference names with links' do
    assign(:conferences, [conference, second_conference])
    render
    expect(rendered).to include('openSUSE Conference 2016')
    expect(rendered).to include(CGI.escapeHTML(second_conference.title))
  end
end
