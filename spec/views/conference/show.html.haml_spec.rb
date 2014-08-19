require 'spec_helper'
describe 'conference/show.html.haml' do
  before(:each) do
    allow(view).to receive(:date_string).and_return('January 17 - 21 2014')
    @conference = create(:conference,
                         sponsor_email: 'example@example.com')

    @conference.splashpage = create(:splashpage,
                                    banner_description: 'Lorem Ipsum',
                                    sponsor_description: 'Lorem Ipsum Dolor',
                                    registration_description: 'Lorem Ipsum Dolor',
                                    include_registrations: true,
                                    include_program: true,
                                    include_sponsors: true,
                                    include_tracks: true,
                                    include_tickets: true,
                                    include_banner: true,
                                    include_social_media: true,
                                    include_venue: true,
                                    include_lodgings: true)
    @conference.contact.update(facebook: 'http://www.fbexample.com',
                               googleplus: 'http://www.google-example.com',
                               instagram: 'http://instagram.com',
                               twitter: 'http://twitter.com')
    @conference.registration_period = create(:registration_period,
                                             start_date: Date.today,
                                             end_date: Date.tomorrow)
    @conference.call_for_papers = create(:call_for_papers, conference: @conference,
                                                           include_cfp_in_splash: true)
    @conference.call_for_papers = create(:call_for_papers, conference: @conference,
                                                           include_cfp_in_splash: true)
    @conference.sponsorship_levels << create(:sponsorship_level, conference: @conference)
    @sponsorship_level = @conference.sponsorship_levels.first
    @sponsorship_level.sponsors << create(:sponsor, sponsorship_level: @sponsorship_level,
                                                    conference: @conference)
    @conference.venue = create(:venue)
    @conference.venue.lodgings << create(:lodging, venue: @conference.venue)
    assign :conference, @conference
    render
  end

  it 'renders banner component' do
    expect(view.content_for(:splash)).to include("#{@conference.splashpage.banner_description}")
    expect(view.content_for(:splash)).to include("#{@conference.short_title}")
  end

  it 'renders program partial' do
    expect(view).to render_template(partial: 'conference/_program')
  end

  it 'renders registration partial' do
    expect(view.content_for(:splash)).to include("#{@conference.splashpage.registration_description}")
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
