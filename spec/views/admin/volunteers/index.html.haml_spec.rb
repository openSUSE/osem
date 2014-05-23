require 'spec_helper'

describe 'admin/volunteers/index' do

  it 'renders volunteers days as vdays' do
    @vday = create(:vday)
    @vday.conference.update_attributes(use_volunteers: true, use_vdays: true)
    assign :conference, @vday.conference
    render
    expect(rendered).to have_selector(
        "input[checked='checked'][type='checkbox'][value='1']", count: 2)
    expect(rendered).to include("#{Date.today.strftime('%Y')}")
    expect(rendered).to include("#{Date.today.strftime('%B')}")
    expect(rendered).to include("#{Date.today.strftime('%d')}")
    expect(rendered).to include('Lorem Ipsum dolsum')
  end

  it 'renders volunteers positions as vpositions' do
    @vposition = create(:vposition)
    @vposition.conference.update_attributes(
        use_vpositions: true, use_volunteers: true, use_vdays: true)
    assign :conference, @vposition.conference
    render
    expect(rendered).to include("#{Date.today}")
    expect(rendered).to include('Example Volunteer Position')
    expect(rendered).to include('Lorem Ipsum dolsum')
  end
end
