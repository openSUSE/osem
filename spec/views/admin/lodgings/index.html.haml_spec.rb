require 'spec_helper'

describe 'admin/lodgings/index' do
  it 'renders lodgings list' do
    @conference = create(:conference)
    @conference.venue = create(:venue)
    @conference.lodgings << create(:lodging)
    assign :venue, @conference.venue
    render
    expect(rendered).to include(CGI.escapeHTML(@conference.lodgings.first.name))
  end
end
