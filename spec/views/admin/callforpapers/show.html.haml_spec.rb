require 'spec_helper'
describe 'admin/callforpapers/show' do
  it 'renders conference sidebar' do
    assign :cfp, CallForPapers.new
    expect(sidebar).to be true
  end
  it 'renders callforpapers details' do
    @conference = create(:conference)
    assign :conference, @conference
    assign :cfp, stub_model(CallForPapers, start_date: Date.today,
                                           end_date: Date.today + 7.days,
                                           hard_deadline: Date.today + 6.days,
                                           description: 'Lorem Ipsum Dolsum')
    render
    expect(rendered).to include("#{Date.today}")
    expect(rendered).to include("#{Date.today + 7.days}")
    expect(rendered).to include('Lorem Ipsum Dolsum')
  end

end
