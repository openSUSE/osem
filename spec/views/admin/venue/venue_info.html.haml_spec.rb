require 'spec_helper'

describe 'admin/venue/venue_info' do
  it 'renders conference sidebar' do
    assign :venue, stub_model(Venue)
    expect(sidebar).to be true
  end
  it 'renders venue#show' do
    @conference = create(:conference)
    @venue = @conference.venue
    @venue.name = 'Croatia'
    @venue.description = 'Lorem ipsum dolsum'
    @venue.save!
    assign :conference, @conference
    assign :venue, @venue
    render
    expect(rendered).to include('Croatia')
    expect(rendered).to include('Lorem ipsum dolsum')
  end
end
