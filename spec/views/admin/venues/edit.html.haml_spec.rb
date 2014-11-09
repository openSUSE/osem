require 'spec_helper'

describe 'admin/venues/edit' do

  it 'renders venues#show' do
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
