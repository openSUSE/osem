require 'spec_helper'

describe 'admin/call_for_papers/show' do

  it 'renders call for papers details' do
    assign :conference, create(:conference)
    assign :call_for_paper, create(:call_for_paper)
    render
    expect(rendered).to include('Start Date')
    expect(rendered).to include('End Date')
    expect(rendered).to include(1.day.ago.strftime('%A, %B %-d. %Y'))
    expect(rendered).to include(6.days.from_now.strftime('%A, %B %-d. %Y'))
  end

end
