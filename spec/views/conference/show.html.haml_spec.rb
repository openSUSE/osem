require 'spec_helper'
describe 'conference/show.html.haml' do
  before(:each) do
    @conference = create(:conference, registration_description: 'Lorem Ipsum Dolor',
                                      registration_start_date: Date.today,
                                      registration_end_date: Date.tomorrow,
                                      description: 'Lorem Ipsum')
    @conference.venue = create(:venue)
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
    expect(view).to render_template(partial: 'conference/_call_for_papers')
    expect(rendered).to include("#{@conference.call_for_papers.description}")
  end

  it 'renders location partial' do
    expect(view).to render_template(partial: 'conference/_location')
    expect(rendered).to include('Suse Office')
    expect(rendered).to include('Maxfeldstrasse 5 \n90409 Nuremberg')
    expect(rendered).to include('www.opensuse.org')
    expect(rendered).to include('Lorem Ipsum Dolor')
  end
end
