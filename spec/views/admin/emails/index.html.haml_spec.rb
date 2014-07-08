require 'spec_helper'
describe 'admin/emails/index' do

  it 'renders email templates' do
    @conference = create(:conference)
    assign :conference, @conference
    @settings = create(:email_settings)
    assign :settings, @settings
    render
    expect(rendered).
        to have_selector("input[type='checkbox'][value='1']", count: 5)
    expect(rendered).
        to have_selector("input[checked='checked'][type='checkbox'][value='1']", count: 2)
    expect(rendered).to include('Lorem Ipsum Dolsum')
    expect(rendered).
        to include('Lorem ipsum dolor sit amet, consectetuer adipiscing elit')
    expect(rendered).
        to include('Conference dates have been updated')
  end
end
