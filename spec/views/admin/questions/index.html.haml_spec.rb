require 'spec_helper'

describe 'admin/questions/index' do
  let!(:conference) { create(:conference) }
  let!(:question_type) { create(:question_type) }

  before(:each) do
    assign(:conference, conference)
    assign(:question, build(:question))
    assign(:questions, [ create(:attending_with_partner), create(:question_with_answers, conference_id: conference.id, title: 'Test question for this conf', question_type_id: question_type.id)])

    render
  end

  it 'renders all available questions' do
    expect(rendered).to have_selector('table th:nth-of-type(1)', text: 'Enabled')
    expect(rendered).to have_selector('table th:nth-of-type(2)', text: 'Title')
    expect(rendered).to have_selector('table th:nth-of-type(3)', text: 'Type')
    expect(rendered).to have_selector('table th:nth-of-type(4)', text: 'Answers')
    expect(rendered).to have_selector('table th:nth-of-type(5)', text: 'Actions')

    expect(rendered).to have_selector('table tr:nth-of-type(1) td:nth-of-type(2)', text: 'Will you attend with a partner?')
    expect(rendered).to have_selector('table tr:nth-of-type(1) td:nth-of-type(3)', text: 'Yes/No')
    expect(rendered).to have_selector('table tr:nth-of-type(1) td:nth-of-type(4)', text: 'Yes (0), No (0)')

    expect(rendered).to have_selector('table tr:nth-of-type(2) td:nth-of-type(2)', text: 'Test question for this conf')
    expect(rendered).to have_selector('table tr:nth-of-type(2) td:nth-of-type(3)', text: 'A type for question')
    expect(rendered).to have_selector('table tr:nth-of-type(2) td:nth-of-type(4)', text: 'First Answer (0), Second Answer (0)')
  end
end
