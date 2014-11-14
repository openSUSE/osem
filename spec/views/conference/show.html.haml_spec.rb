require 'spec_helper'
describe 'conference/show.html.haml' do
  before(:each) do
    allow(view).to receive(:date_string).and_return('January 17 - 21 2014')
    @conference = create(:conference)

    @conference.splashpage = create(:splashpage,
                                    banner_description: 'Banner Description',
                                    sponsor_description: 'Sponsor Description',
                                    registration_description: 'Registration Description',
                                    include_registrations: true,
                                    include_program: true,
                                    include_sponsors: true,
                                    include_tracks: true,
                                    include_tickets: true,
                                    include_banner: true,
                                    include_social_media: true,
                                    include_venue: true,
                                    include_lodgings: true)

    @conference.contact.update(sponsor_email: 'example@example.com',
                               facebook: 'http://facebook.com',
                               googleplus: 'http://google.com',
                               instagram: 'http://instagram.com',
                               twitter: 'http://twitter.com')

    @conference.registration_period = create(:registration_period,
                                             start_date: Date.yesterday,
                                             end_date: Date.tomorrow)

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
    expect(rendered).to match(/#{@conference.splashpage.banner_description}/)
    expect(rendered).to match(/#{@conference.short_title}/)
  end

  it 'renders program partial' do
    expect(view).to render_template(partial: 'conference/_program')
  end

  it 'renders registration partial' do
    expect(view).to render_template(partial: 'conference/_registration')
  end

  it 'renders call_for_papers partial' do
    expect(rendered).to match(/#{@conference.call_for_papers.description}/)
  end

  it 'renders sponsors partial' do
    expect(view).to render_template(partial: 'conference/_sponsors')
    expect(rendered).to match(/example@example.com/)
    expect(rendered).to match(/Platin/)
    expect(rendered).to match(/Example sponsor/)
    expect(rendered).to match(/www.example.com/)
    expect(rendered).to match(/Lorem Ipsum Dolor/)
    expect(rendered).to match(/rails.jpg/)
  end

  it 'renders social media partial' do
    expect(view).to render_template('conference/_social_media')
    expect(rendered).to match(/facebook.com/)
    expect(rendered).to match(/google.com/)
    expect(rendered).to match(/instagram.com/)
    expect(rendered).to match(/twitter.com/)
  end

  it 'renders location partial' do
    expect(view).to render_template(partial: 'conference/_location')
    expect(rendered).to match(/Suse Office/)
    expect(rendered).to match(/Maxfeldstrasse 5/)
    expect(rendered).to match(/www.opensuse.org/)
    expect(rendered).to match(/Lorem Ipsum Dolor/)
  end

  it 'renders lodging partial' do
    expect(view).to render_template(partial: 'conference/_lodging')
    expect(rendered).to match(/Example Hotel/)
    expect(rendered).to match(/Lorem Ipsum Dolor/)
    expect(rendered).to match(/www.example.com/)
  end
end
