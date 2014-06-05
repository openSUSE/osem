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
    expect(rendered).to include('Example sponsor')
    expect(rendered).to include('http://www.example.com')
    expect(rendered).to include('Lorem Ipsum Dolor')
    expect(rendered).to include('Platin')
  end
end
