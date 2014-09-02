require 'spec_helper'

describe 'admin/conference/roles' do
  let(:conference) { create(:conference) }
  let(:organizer_role) { create(:organizer_role, description: 'My description for organizer role', resource: conference) }
  let(:organizer) { create(:user, name: 'test name', email: 'test@email.com', role_ids: [organizer_role.id]) }

  it 'renders the roles template for the conference' do
    assign :conference, conference
    assign :selection, 'organizer'
    assign :role, [organizer_role]
    assign :role_users, 'organizer' => [organizer]
    render
    expect(rendered).to include('Show users for role:')
    expect(rendered).to include(organizer_role.description)
    expect(rendered).to include("Add role 'Organizer' to user:")
    expect(rendered).to include('Add role')
    expect(rendered).to include('Users with role Organizer')
    expect(rendered).to have_selector('table thead th:nth-of-type(1)', text: 'ID')
    expect(rendered).to have_selector('table thead th:nth-of-type(2)', text: 'Name')
    expect(rendered).to have_selector('table thead th:nth-of-type(3)', text: 'Email')
    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(1)', text: organizer.id)
    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(2)', text: 'test name')
    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(3)', text: 'test@email.com')
  end
end
