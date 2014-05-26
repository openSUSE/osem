require 'spec_helper'
describe 'conference/show.html.haml' do
  it 'renders conference details' do 
    @sponsorship_registration = create(:sponsorship_registration)
    @conference = @sponsorship_registration.conference
    assign :conference, @conference
    render
    expect(view).to render_template(:partial => "conference/_sponsor")
    expect(rendered).to include("#{@sponsorship_registration.sponsorship_level.title}")
  end

end
