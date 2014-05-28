require 'spec_helper'
describe 'conference/show.html.haml' do
  it 'renders program partial' do
    @conference = create(:conference, description: 'Lorem Ipsum')
    assign :conference, @conference
    render
    expect(render).to include("#{@conference.description}")
    expect(view).to render_template(partial: 'conference/_program')
  end

  it 'renders registration partial' do
    @conference = create(:conference, registration_description: 'Lorem Ipsum Dolor',
                                      registration_start_date: Date.today,
                                      registration_end_date: Date.tomorrow)
    assign :conference, @conference
    render
    expect(rendered).to include("#{@conference.registration_description}")
    expect(rendered).to include("Register for #{@conference.short_title}")
    expect(view).to render_template(partial: 'conference/_registration')
  end
end
