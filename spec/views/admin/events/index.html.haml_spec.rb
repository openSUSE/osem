require 'spec_helper'

describe 'admin/events/index' do
  let!(:conference) { create(:conference) }
  let!(:program) { conference.program }
  let!(:event1) { create(:event, program: conference.program, title: 'event1', language: 'English') }
  let!(:event2) { create(:event, program: conference.program, title: 'event2', language: 'German') }

  it 'renders all conference events' do
    assign(:conference, conference)
    assign(:program, conference.program)
    program.languages = 'en,de'
    assign(:events, [ event1, event2 ])
    assign(:event_types, [ create(:event_type, program: conference.program), create(:event_type, program: conference.program) ])
    assign(:tracks, [ create(:track, program: conference.program), create(:track, program: conference.program) ])
    assign(:difficulty_levels, [ create(:difficulty_level, program: conference.program), create(:difficulty_level, program: conference.program) ])

    render

    expect(rendered).to have_selector('table thead th:nth-of-type(1)', text: 'ID')
    expect(rendered).to have_selector('table thead th:nth-of-type(2)', text: 'Title')
    expect(rendered).to have_selector('table thead th:nth-of-type(3)', text: 'Submitter')
    expect(rendered).to have_selector('table thead th:nth-of-type(4)', text: 'Speaker')
    expect(rendered).to have_selector('table thead th:nth-of-type(5)', text: 'Language')
    expect(rendered).to have_selector('table thead th:nth-of-type(6)', text: 'Requires Registration')
    expect(rendered).to have_selector('table thead th:nth-of-type(7)', text: 'Highlight')
    expect(rendered).to have_selector('table thead th:nth-of-type(8)', text: 'Type')
    expect(rendered).to have_selector('table thead th:nth-of-type(9)', text: 'Track')
    expect(rendered).to have_selector('table thead th:nth-of-type(10)', text: 'Difficulty')
    expect(rendered).to have_selector('table thead th:nth-of-type(11)', text: 'State')

    expect(conference.program.events.count).to eq 2
    expect(rendered).to have_selector('table tr:nth-of-type(1) td:nth-of-type(1)', text: event1.id)
    expect(rendered).to have_selector('table tr:nth-of-type(1) td:nth-of-type(2)', text: 'event1')
    expect(rendered).to have_selector('table tr:nth-of-type(1) td:nth-of-type(5)', text: 'English')

    expect(rendered).to have_selector('table tr:nth-of-type(2) td:nth-of-type(1)', text: event2.id)
    expect(rendered).to have_selector('table tr:nth-of-type(2) td:nth-of-type(2)', text: 'event2')
    expect(rendered).to have_selector('table tr:nth-of-type(2) td:nth-of-type(5)', text: 'German')
  end
end
