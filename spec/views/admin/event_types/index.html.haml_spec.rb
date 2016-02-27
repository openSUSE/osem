require 'spec_helper'

describe 'admin/event_types/index' do

  it 'renders event types' do
    conference = create(:conference)
    @event_type = create(:event_type, program: conference.program)
    assign :conference, @event_type.program.conference
    render
    expect(rendered).to include('Example Event Type')
    expect(rendered).to include('30')
    expect(rendered).to include('0')
    expect(rendered).to include('500')
  end
end
