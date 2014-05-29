require 'spec_helper'
describe 'conference/show.html.haml' do
  before(:each) do
    @conference = create(:conference, registration_description: 'Lorem Ipsum Dolor',
                                      registration_start_date: Date.today,
                                      registration_end_date: Date.tomorrow,
                                      description: 'Lorem Ipsum')
    assign :conference, @conference
    render
  end
  it 'renders program partial' do
    expect(render).to include("#{@conference.description}")
    expect(view).to render_template(partial: 'conference/_program')
  end

  it 'renders registration partial' do
    expect(rendered).to include("#{@conference.registration_description}")
    expect(view).to render_template(partial: 'conference/_registration')
  end
end
