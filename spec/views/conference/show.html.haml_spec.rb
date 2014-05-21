require 'spec_helper'
describe 'conference/show.html.haml' do
  it 'renders conference details' do 
    @conference = create(:conference, description: 'Lorem Ipsum dolsum')
    assign :conference, @conference
    render
    expect(render).to include("#{@conference.description}")
  end

end
