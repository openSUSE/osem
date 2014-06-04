require 'spec_helper'
describe 'admin/callforpapers/show' do

  it 'renders callforpapers details' do
    @conference = create(:conference)
    assign :conference, @conference
    assign :cfp, stub_model(CallForPapers, start_date: Date.today,
                                           end_date: Date.today + 7.days,
                                           description: 'Lorem Ipsum Dolsum')
    render
    expect(rendered).to include("#{Date.today}")
    expect(rendered).to include("#{Date.today + 7.days}")
    expect(rendered).to include('Lorem Ipsum Dolsum')
  end

end
