require 'spec_helper'

describe 'admin/social_events/index' do

  it 'renders social events' do
    @social_event = create(:social_event)
    assign :conference, @social_event.conference
    render
    expect(rendered).to include('Example Social Event')
    expect(rendered).to include('Lorem Ipsum Dolsum')
    expect(rendered).to include("#{Date.today.strftime('%Y')}")
    expect(rendered).to include("#{Date.today.strftime('%B')}")
    expect(rendered).to include("#{Date.today.strftime('%-d')}")
  end
end
