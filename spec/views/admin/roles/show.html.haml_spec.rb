require 'spec_helper'

describe 'admin/roles/show' do
  let(:conference) { create(:conference) }
  let(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let(:organizer) { create(:user, name: 'test name', email: 'test@email.osem', role_ids: [organizer_role.id]) }

  before(:each) do
    sign_in organizer
    assign :conference, conference
    assign :selection, 'organizer'
    assign :role, organizer_role
    assign :users, [organizer]
    render
  end

  it 'renders show properly' do
    expect(rendered).to include(organizer_role.name.capitalize)
    expect(rendered).to include('Add user by email:')
    expect(rendered).to have_selector('table thead th:nth-of-type(1)', text: '')
    expect(rendered).to have_selector('table thead th:nth-of-type(2)', text: 'ID')
    expect(rendered).to have_selector('table thead th:nth-of-type(3)', text: 'Name')
    expect(rendered).to have_selector('table thead th:nth-of-type(4)', text: 'Email')
    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(2)', text: organizer.id)
    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(3)', text: 'test name')
    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(4)', text: 'test@email.osem')
  end
end
