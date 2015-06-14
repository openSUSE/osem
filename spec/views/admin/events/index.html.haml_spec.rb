require 'spec_helper'

describe 'admin/events/index' do
  let!(:conference) { create(:conference) }
  let!(:event1) { create(:event, conference: conference, title: 'event1') }
  let!(:event2) { create(:event, conference: conference, title: 'event2') }

  it 'renders all conference events' do
    assign(:conference, conference)
    assign(:events, [ event1, event2 ])
    assign(:event_types, [ create(:event_type, conference: conference), create(:event_type, conference: conference) ])
    assign(:tracks, [ create(:track, conference: conference), create(:track, conference: conference) ])
    assign(:difficulty_levels, [ create(:difficulty_level, conference: conference), create(:difficulty_level, conference: conference) ])

    render

    expect(rendered).to have_selector('table thead th:nth-of-type(1)', text: 'ID')
    expect(rendered).to have_selector('table thead th:nth-of-type(2)', text: 'Title')
    expect(rendered).to have_selector('table thead th:nth-of-type(3)', text: 'Submitter')
    expect(rendered).to have_selector('table thead th:nth-of-type(4)', text: 'Speaker')
    expect(rendered).to have_selector('table thead th:nth-of-type(5)', text: 'Pre-registration')
    expect(rendered).to have_selector('table thead th:nth-of-type(6)', text: 'Highlight')
    expect(rendered).to have_selector('table thead th:nth-of-type(7)', text: 'Type')
    expect(rendered).to have_selector('table thead th:nth-of-type(8)', text: 'Track')
    expect(rendered).to have_selector('table thead th:nth-of-type(9)', text: 'Difficulty')
    expect(rendered).to have_selector('table thead th:nth-of-type(10)', text: 'State')

    expect(conference.events.count).to eq 2
    expect(rendered).to have_selector('table tr:nth-of-type(1) td:nth-of-type(1)', text: event1.id)
    expect(rendered).to have_selector('table tr:nth-of-type(1) td:nth-of-type(2)', text: 'event1')

    expect(rendered).to have_selector('table tr:nth-of-type(2) td:nth-of-type(1)', text: event2.id)
    expect(rendered).to have_selector('table tr:nth-of-type(2) td:nth-of-type(2)', text: 'event2')
  end
end
