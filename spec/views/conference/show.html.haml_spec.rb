require 'spec_helper'
describe 'conference/show.html.haml' do
  before(:each) do
    @conference = create(:conference, registration_description: 'Lorem Ipsum Dolor',
                                      registration_start_date: Date.today,
                                      registration_end_date: Date.tomorrow,
                                      description: 'Lorem Ipsum',
                                      sponsor_description: 'Lorem Ipsum Dolor',
                                      sponsor_email: 'example@example.com',
                                      facebook_url: 'http://www.fbexample.com',
                                      google_url: 'http://www.google-example.com',
                                      media_type: 'YouTube',
                                      media_id: 'rtyutut')
    @conference.call_for_papers = create(:call_for_papers, conference: @conference)
    @conference.sponsorship_levels << create(:sponsorship_level, conference: @conference)
    @sponsorship_level = @conference.sponsorship_levels.first
    @sponsorship_level.sponsors << create(:sponsor, sponsorship_level: @sponsorship_level,
                                                    conference: @conference)
    @conference.venue = create(:venue)
    @conference.venue.lodgings << create(:lodging, venue: @conference.venue)
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

  it 'renders call_for_papers partial' do
    expect(render).to include("#{@conference.call_for_papers.description}")
  end

  it 'renders sponsors partial' do
    expect(view).to render_template(partial: 'conference/_sponsor')
    expect(rendered).to include('Lorem Ipsum Dolor')
    expect(rendered).to include('example@example.com')
    expect(rendered).to include('Platin')
    expect(rendered).to include('Example sponsor')
    expect(rendered).to include('http://www.example.com')
    expect(rendered).to include('Lorem Ipsum Dolor')
    expect(rendered).to include('rails.jpg')
  end

  it 'renders social media partial' do
    expect(view).to render_template('conference/_social_media')
    expect(rendered).to include('http://www.fbexample.com')
    expect(rendered).to include('http://www.google-example.com')
    expect(rendered).to include('http://youtu.be/rtyutut')
  end

  it 'renders location partial' do
    expect(view).to render_template(partial: 'conference/_location')
    expect(rendered).to include('Suse Office')
    expect(rendered).to include('Maxfeldstrasse 5 \n90409 Nuremberg')
    expect(rendered).to include('www.opensuse.org')
    expect(rendered).to include('Lorem Ipsum Dolor')
  end

  it 'renders lodging partial' do
    expect(view).to render_template(partial: 'conference/_lodging')
    expect(rendered).to include('Example Hotel')
    expect(rendered).to include('Lorem Ipsum Dolor')
    expect(rendered).to include('http://www.example.com')
  end
end
