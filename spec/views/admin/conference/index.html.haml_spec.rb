require 'spec_helper'

describe 'admin/conference/index' do
  it 'renders all conference names with links' do
    con1 = create(:conference, title: 'OpenSUSE')
    con2 = create(:conference)

    assign(:conferences, [con1, con2])

    status = {}
    status[con1.title] = con1.get_status
    status[con2.title] = con2.get_status
    assign(:conference_progress, status)

    render
    expect(rendered).to include('OpenSUSE')
    expect(rendered).to include("The dog and pony show")
  end
end
