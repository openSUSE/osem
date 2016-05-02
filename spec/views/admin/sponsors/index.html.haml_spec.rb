require 'spec_helper'

describe 'admin/sponsors/index' do
  it 'renders sponsorships' do
    @conference = create(:conference)
    @conference.sponsorship_levels << create(:sponsorship_level, conference: @conference)
    @conference.sponsors << create(:sponsor, conference: @conference,
                                             sponsorship_level: @conference.sponsorship_levels.first
                                             )
    assign :conference, @conference
    render
    expect(rendered).to include(CGI.escapeHTML(@conference.sponsors.first.name))
    expect(rendered).to include(@conference.sponsors.first.website_url)
    expect(rendered).to include(truncate(CGI.escapeHTML(@conference.sponsors.first.description)))
    expect(rendered).to include(CGI.escapeHTML(@conference.sponsorship_levels.first.title))
  end
end
