require 'spec_helper'

describe 'admin/tracks/index' do

  it 'renders tracks' do
    conference = create(:conference)
    create(:track, name: 'Example Track', description: 'Lorem Ipsum dolsum', color: '#ffffff', program: conference.program)
    assign :tracks, conference.program.tracks
    assign :conference, conference
    render
    expect(rendered).to include('Example Track')
    expect(rendered).to include('Lorem Ipsum dolsum')
    expect(rendered).to include('#FFFFFF')
  end
end
