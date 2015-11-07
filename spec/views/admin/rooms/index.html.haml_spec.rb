require 'spec_helper'

describe 'admin/rooms/index' do

  it 'renders rooms list' do
    conference = create(:conference)
    venue = create(:venue, conference: conference)
    room = create(:room, name: 'Example Room', size: 4, venue: venue)
    assign :conference, conference
    assign :rooms, [room]
    render
    expect(rendered).to include('Example Room')
    expect(rendered).to include('4')
  end

end
