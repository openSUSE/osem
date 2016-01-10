require 'spec_helper'

describe 'admin/questions/show' do
  let!(:conference) { create(:conference) }
  let!(:question_type) { create(:question_type) }
  let!(:question) { create(:question) }
  let!(:attending_with_partner) { create(:attending_with_partner) }
  let!(:user1) { create(:user, name: 'User 1') }
  let!(:user2) { create(:user, name: 'User 2') }
  let!(:user3) { create(:user, name: 'User 3') }

  let!(:registration1) { create(:registration, conference: conference, user: user1) }
  let!(:qanswer1) { create(:qanswer, question: attending_with_partner, answer: attending_with_partner.answers.first) }
  let!(:registration2) { create(:registration, conference: conference, user: user2) }
  let!(:qanswer2) { create(:qanswer, question: attending_with_partner, answer: attending_with_partner.answers.second) }
  let!(:registration3) { create(:registration, conference: conference, user: user3) }

  before(:each) do
    assign :conference, conference
    assign :question, attending_with_partner
    assign :registrations, [registration1, registration2]
    registration1.qanswers = [qanswer1]
    registration2.qanswers = [qanswer2]
    render
  end

  it 'renders all users that answered the question' do
    expect(rendered).to include('User 1')
    expect(rendered).to include('User 2')
  end

  it 'does not render users that have not answered the question' do
    expect(rendered).to_not include('User 3')
  end
end
