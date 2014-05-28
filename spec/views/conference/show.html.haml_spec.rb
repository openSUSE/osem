require 'spec_helper'
describe 'conference/show.html.haml' do
  it 'renders program partial' do
    @conference = create(:conference, description: 'Lorem Ipsum')
    assign :conference, @conference
    render
    expect(render).to include("#{@conference.description}")
    expect(view).to render_template(partial: 'conference/_program')
  end
end
