require 'spec_helper'
describe 'conference/show.html.haml' do
  before(:each) do
    @conference = create(:conference, registration_description: 'Lorem Ipsum Dolor',
                                      registration_start_date: Date.today,
                                      registration_end_date: Date.tomorrow,
                                      description: 'Lorem Ipsum',
                                      facebook_url: 'http://www.fbexample.com',
                                      google_url: 'http://www.google-example.com',
                                      media_type: 'YouTube',
                                      media_id: 'rtyutut')
    @conference.call_for_papers = create(:call_for_papers, conference: @conference)
    assign :conference, @conference
    render
  end

  it 'renders program partial' do
    expect(rendered).to include("#{@conference.description}")
    expect(view).to render_template(partial: 'conference/_program')
  end

  it 'renders registration partial' do
    expect(rendered).to include("#{@conference.registration_description}")
    expect(view).to render_template(partial: 'conference/_registration')
  end

  it 'renders call_for_papers partial' do
    expect(rendered).to include("#{@conference.call_for_papers.description}")
  end

  it 'renders social media partial' do
    expect(view).to render_template('conference/_social_media')
    expect(rendered).to include('http://www.fbexample.com')
    expect(rendered).to include('http://www.google-example.com')
    expect(rendered).to include('http://youtu.be/rtyutut')
  end
end
