require 'spec_helper'

describe 'layouts/application.haml' do
  let(:conference) { create(:conference) }

  it 'assigns a class to the body identifying the current conference' do
    assign(:conference, conference)
    render
    expect(rendered).to have_selector("body.conference-#{conference.short_title}")
  end
end
