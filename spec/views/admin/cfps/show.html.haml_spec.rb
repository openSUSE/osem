require 'spec_helper'

describe 'admin/cfps/show' do

  it 'renders call for papers details' do
    conference = create(:conference)
    assign :conference, conference
    assign :program, conference.program
    assign :cfp, create(:cfp, program: conference.program)
    render
    expect(rendered).to include('Start Date')
    expect(rendered).to include('End Date')
    expect(rendered).to include(1.day.ago.strftime('%A, %B %-d. %Y'))
    expect(rendered).to include(6.days.from_now.strftime('%A, %B %-d. %Y'))
  end

end
