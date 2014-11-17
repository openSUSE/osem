require 'spec_helper'

describe 'conference/index' do
  it 'renders _conference partial for each conference' do
    allow(view).to receive(:date_string).and_return('January 17 - 21 2014')
    assign(:current, [create(:conference), create(:conference)])
    render
    expect(view).to render_template(partial: '_conference_details', count: 2)
  end
end
