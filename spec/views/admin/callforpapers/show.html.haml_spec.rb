require 'spec_helper'

describe 'admin/callforpapers/show' do

  it 'renders callforpapers details' do
    assign :conference, create(:conference)
    assign :cfp, create(:call_for_papers)
    render
    expect(rendered).to include(1.day.ago.strftime('%Y-%m-%d'))
    expect(rendered).to include(7.days.from_now.strftime('%Y-%m-%d'))
    expect(rendered).to include('We call for papers')
  end

end
