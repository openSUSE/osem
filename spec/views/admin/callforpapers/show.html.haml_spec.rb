require 'spec_helper'

describe 'admin/callforpapers/show' do

  it 'renders callforpapers details' do
    @conference = create(:conference)
    assign :conference, @conference
    assign :cfp, stub_model(CallForPapers, start_date: Date.today,
                                           end_date: Date.today + 7.days,
                                           description: 'Lorem Ipsum Dolsum')
    render
    expect(rendered).to include(Date.today.strftime('%Y-%m-%d'))
    expect(rendered).to include(7.days.from_now.strftime('%Y-%m-%d'))
    expect(rendered).to include('Lorem Ipsum Dolsum')
  end

end
