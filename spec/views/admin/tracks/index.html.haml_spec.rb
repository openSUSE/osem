require 'spec_helper'

describe "admin/tracks/index" do
  it 'renders conference sidebar' do
    expect(sidebar).to be true
  end
  it 'renders tracks' do
    @track = create(:track)
    assign :conference, @track.conference
    render
    expect(rendered).to include('Example Track')
    expect(rendered).to include('Lorem Ipsum dolsum')
    expect(rendered).to include('#ffffff')
  end
end
