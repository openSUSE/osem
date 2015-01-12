require 'spec_helper'

describe 'admin/roles/index' do
  let(:conference) { create(:conference) }
  let(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, name: 'user name for organizer', email: 'organizer@osem.io', role_ids: organizer_role.id) }

  let(:cfp_role) { Role.find_by(name: 'cfp', resource: conference) }
  let!(:cfp_user) { create(:user, name: 'user name for cfp', email: 'cfp@osem.io', role_ids: [cfp_role.id]) }

  let(:info_desk_role) { Role.find_by(name: 'info_desk', resource: conference) }
  let(:volunteers_coordinator_role) { Role.find_by(name: 'volunteers_coordinator', resource: conference) }

  before(:each) do
    assign :conference, conference
    assign :roles, [organizer_role, cfp_role, info_desk_role, volunteers_coordinator_role]

    render
  end

  it 'renders index' do
    expect(organizer_role.users.count).to eq 1
    expect(rendered).to have_selector('table thead th:nth-of-type(1)', text: 'ID')
    expect(rendered).to have_selector('table thead th:nth-of-type(2)', text: 'Name')
    expect(rendered).to have_selector('table thead th:nth-of-type(3)', text: 'Description')
    expect(rendered).to have_selector('table thead th:nth-of-type(4)', text: 'Users')
    expect(rendered).to have_selector('table thead th:nth-of-type(5)', text: 'Actions')

    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(1)', text: organizer_role.id)
    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(2)', text: 'Organizer')
    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(3)', text: 'For the organizers of the conference (who shall have full access)')
    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(4)', text: 'user name for organizer')
    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(5)', text: 'Users')

    expect(rendered).to have_selector('table tbody tr:nth-of-type(2) td:nth-of-type(1)', text: cfp_role.id)
    expect(rendered).to have_selector('table tbody tr:nth-of-type(2) td:nth-of-type(2)', text: 'Cfp')
    expect(rendered).to have_selector('table tbody tr:nth-of-type(2) td:nth-of-type(3)', text: 'For the members of the CfP team')
    expect(rendered).to have_selector('table tbody tr:nth-of-type(2) td:nth-of-type(4)', text: 'user name for cfp')
    expect(rendered).to have_selector('table tbody tr:nth-of-type(2) td:nth-of-type(5)', text: 'Users')
  end
end
