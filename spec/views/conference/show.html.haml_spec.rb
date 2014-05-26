require 'spec_helper'
describe 'conference/show.html.haml' do
  it 'renders conference details' do 
    @conference = create(:conference)
    @conference.registration_description = 'Lorem Ipsum'
    @conference.registration_start_date = Date.today
    @conference.registration_end_date = Date.today + 7.days
    @conference.use_supporter_levels = true
    @conference.save!
    @conference.supporter_levels = [create(:supporter_level)]
    assign :conference, @conference
    render
    expect(render).to include("#{ @conference.registration_description }")
    expect(render).to include('Example Supporter Level')
  end

end
