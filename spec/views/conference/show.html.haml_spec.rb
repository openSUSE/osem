require 'spec_helper'
describe 'conference/show.html.haml' do
  let!(:conference) { create(:full_conference) }

  before(:each) do
    allow(view).to receive(:date_string).and_return('January 17 - 21 2014')
    assign :conference, conference
    render
  end

  it 'renders banner component' do
    expect(rendered).to match(CGI.escapeHTML(conference.description))
  end

  it 'renders program partial' do
    expect(view).to render_template(partial: 'conference/_schedule_splashpage')
  end

  it 'renders registration partial' do
    expect(view).to render_template(partial: 'conference/_registration')
  end

  it 'renders call_for_paper partial' do
    expect(rendered).to match(/We are ready to accept your proposals for sessions!/)
  end

  it 'renders sponsors partial' do
    expect(view).to render_template(partial: 'conference/_sponsors')
    expect(rendered).to match(conference.contact.email)
    expect(rendered).to match(conference.sponsors.first.website_url)
    expect(rendered).to match(CGI.escapeHTML(conference.sponsors.first.description))
    expect(rendered).to match(conference.sponsors.first.logo_file_name)
  end

  it 'renders social media partial' do
    expect(view).to render_template('conference/_social_media')
    expect(rendered).to match(conference.contact.facebook)
    expect(rendered).to match(conference.contact.googleplus)
    expect(rendered).to match(conference.contact.instagram)
    expect(rendered).to match(conference.contact.twitter)
  end

  it 'renders venue partial' do
    expect(view).to render_template(partial: 'conference/_venue')
    expect(rendered).to match(CGI.escapeHTML(conference.venue.name))
    expect(rendered).to match(conference.venue.street)
    expect(rendered).to match(conference.venue.website)
    expect(rendered).to match(CGI.escapeHTML(conference.venue.description))
  end

  it 'renders lodging partial' do
    expect(view).to render_template(partial: 'conference/_lodging')
    expect(rendered).to match(CGI.escapeHTML(conference.lodgings.first.name))
    expect(rendered).to match(CGI.escapeHTML(conference.lodgings.first.description))
    # FIXME: Lodging without image doesn't show link
    # expect(rendered).to match(conference.lodgings.first.website_link)
  end
end
