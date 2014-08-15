require 'spec_helper'
describe 'conference/show.html.haml' do
  before(:each) do
    allow(view).to receive(:date_string).and_return("January 17 - 21 2014")
    @conference = create(:conference, registration_description: 'Lorem Ipsum Dolor',
                                      registration_start_date: Date.today,
                                      registration_end_date: Date.tomorrow,
                                      description: 'Lorem Ipsum',
                                      sponsor_description: 'Lorem Ipsum Dolor',
                                      sponsor_email: 'example@example.com',
                                      include_registrations_in_splash: true,
                                      include_program_in_splash: true,
                                      include_sponsors_in_splash: true,
                                      include_tracks_in_splash: true,
                                      include_tickets_in_splash: true,
                                      include_banner_in_splash: true)
    @conference.contact.update(facebook: 'http://www.fbexample.com',
                               googleplus: 'http://www.google-example.com',
                               instagram: 'http://instagram.com',
                               twitter: 'http://twitter.com',
                               public: true
                               )
    @conference.call_for_papers = create(:call_for_papers, conference: @conference,
                                                           include_cfp_in_splash: true)
    @conference.call_for_papers = create(:call_for_papers, conference: @conference,
                                                           include_cfp_in_splash: true)
    @conference.sponsorship_levels << create(:sponsorship_level, conference: @conference)
    @sponsorship_level = @conference.sponsorship_levels.first
    @sponsorship_level.sponsors << create(:sponsor, sponsorship_level: @sponsorship_level,
                                                    conference: @conference)
    @conference.venue = create(:venue, include_venue_in_splash: true,
                                       include_lodgings_in_splash: true)
    @conference.venue.lodgings << create(:lodging, venue: @conference.venue)
    assign :conference, @conference
    render
  end

  it 'renders banner component' do
    expect(view.content_for(:splash)).to include("#{@conference.description}")
    expect(view.content_for(:splash)).to include("#{@conference.short_title}")
  end

  it 'renders program partial' do
    expect(view).to render_template(partial: 'conference/_program')
  end

  it 'renders registration partial' do
    expect(view.content_for(:splash)).to include("#{@conference.registration_description}")
    expect(view).to render_template(partial: 'conference/_registration')
  end

  it 'renders call_for_papers partial' do
    expect(view.content_for(:splash)).to include("#{@conference.call_for_papers.description}")
  end

  it 'renders sponsors partial' do
    expect(view).to render_template(partial: 'conference/_sponsor')
    expect(view.content_for(:splash)).to include('Lorem Ipsum Dolor')
    expect(view.content_for(:splash)).to include('example@example.com')
    expect(view.content_for(:splash)).to include('Platin')
    expect(view.content_for(:splash)).to include('Example sponsor')
    expect(view.content_for(:splash)).to include('http://www.example.com')
    expect(view.content_for(:splash)).to include('Lorem Ipsum Dolor')
    expect(view.content_for(:splash)).to include('rails.jpg')
  end

  it 'renders social media partial' do
    expect(view).to render_template('conference/_social_media')
    expect(view.content_for(:splash)).to include('http://www.fbexample.com')
    expect(view.content_for(:splash)).to include('http://www.google-example.com')
    expect(view.content_for(:splash)).to include('http://instagram.com')
    expect(view.content_for(:splash)).to include('http://twitter.com')
  end

  it 'renders location partial' do
    expect(view).to render_template(partial: 'conference/_location')
    expect(view.content_for(:splash)).to include('Suse Office')
    expect(view.content_for(:splash)).to include('Maxfeldstrasse 5 \n90409 Nuremberg')
    expect(view.content_for(:splash)).to include('www.opensuse.org')
    expect(view.content_for(:splash)).to include('Lorem Ipsum Dolor')
  end

  it 'renders lodging partial' do
    expect(view).to render_template(partial: 'conference/_lodging')
    expect(view.content_for(:splash)).to include('Example Hotel')
    expect(view.content_for(:splash)).to include('Lorem Ipsum Dolor')
    expect(view.content_for(:splash)).to include('http://www.example.com')
  end
end
