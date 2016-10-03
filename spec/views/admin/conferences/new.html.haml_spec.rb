require 'spec_helper'

describe 'admin/conferences/new' do
  let(:conference) { build(:conference) }

  it 'renders the new template for the conference' do
    assign(:conference, Conference.new)
    render template: 'admin/conferences/new.html.haml'
    expect(rendered).to include('Basic Information')
    assign(:conference, conference)
    render
    expect(rendered).to include(CGI.escapeHTML(conference.title))
  end
end
