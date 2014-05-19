require 'spec_helper'

describe "conference/show.html.haml" do
  it 'renders conference details' do 
    @conference = create(:conference)
    assign :conference, @conference
    render
    expect(render).to include("#{@conference.title}")
  end
end
