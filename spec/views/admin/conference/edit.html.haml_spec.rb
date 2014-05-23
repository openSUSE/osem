require 'spec_helper'

describe 'admin/conference/edit' do

  it 'renders conference details which are editable' do
    @conference = create(:conference, title: 'OpenSUSE')
    assign :conference, @conference
    render template: 'admin/conference/edit.html.haml'
    expect(rendered).to include('OpenSUSE')
    expect(rendered).to include("#{@conference.contact_email}")
  end
end
