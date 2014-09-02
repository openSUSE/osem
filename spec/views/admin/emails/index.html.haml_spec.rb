require 'spec_helper'
describe 'admin/emails/index' do

  it 'renders email templates' do
    @conference = create(:conference)
    assign :conference, @conference
    @settings = create(:email_settings)
    assign :settings, @settings
    render
    expect(rendered).
        to have_selector("input[type='checkbox'][value='1']", count: 9)
    expect(rendered).
        to have_selector("input[checked='checked'][type='checkbox'][value='1']", count: 6)
    expect(rendered).to include('Lorem Ipsum Dolsum')
    expect(rendered).
        to include('Lorem ipsum dolor sit amet, consectetuer adipiscing elit')
    expect(rendered).
        to include('Conference dates have been updated')
    expect(rendered).
        to include('Conference registration dates have been updated')
    expect(rendered).to include('Venue has been updated')
    expect(rendered).to include('Venue has been Updated to Sample Location')
    expect(rendered).
        to include('Call for Papers dates have been updated')
    expect(rendered).
        to include('Please checkout the new updates to submit your proposal for Sample Conference')
    expect(rendered).
        to include('Sample Conference Cfp schedule is Public')
    expect(rendered).
        to include('Call for Papers schedule is Public.Checkout the link')
  end
end
