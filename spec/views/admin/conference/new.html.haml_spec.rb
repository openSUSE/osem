require 'spec_helper'

describe 'admin/conference/new' do
  let(:conference) { build(:conference) }

  it 'renders the new template for the conference' do
    assign(:conference, Conference.new)
    render
    expect(rendered).to include('Basic Information')
    assign(:conference, conference)
    render
    expect(rendered).to include(CGI.escapeHTML(conference.title))
  end
end
