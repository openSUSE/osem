require 'spec_helper'

describe 'admin/conference/new' do
  it 'renders the new template for the conference' do
    assign(:conference, Conference.new)
    render
    expect(rendered).to include('Basic Information')
    assign(:conference, build(:conference))
    render
    expect(rendered).to include('The dog and pony show')
  end
end
