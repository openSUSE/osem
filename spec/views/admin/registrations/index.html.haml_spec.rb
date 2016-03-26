require 'spec_helper'

describe 'admin/registrations/index' do
  let(:conference) { create(:conference, roles: [role1, role2]) }
  let(:user) { create(:user) }
  let(:role1) { create(:organizer_role, users: [user]) }
  let(:role2) { create(:cfp_role, users: [user]) }

  before :each do
    assign :conference, conference
    assign :registrations, [create(:registration, user: user, conference: conference)]

    render
  end

  it 'renders index' do
    expect(rendered).to have_selector('table tbody td', text: user.name)
    expect(rendered).to have_selector('table tbody td span:nth-of-type(1)', text: role1.name.titleize)
    expect(rendered).to have_selector('table tbody td span:nth-of-type(2)', text: role2.name.titleize)
  end
end
