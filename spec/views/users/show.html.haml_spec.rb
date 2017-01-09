require 'spec_helper'

describe 'users/show' do
  let!(:conference) { create(:conference) }
  let(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let(:organizer) { create(:user_xss, name: 'test name', email: 'test@email.osem', role_ids: [organizer_role.id]) }

  it 'renders proposal information' do
    sign_in organizer

    assign :user, organizer

    render template: 'users/show.html.haml'

    expect(rendered).to_not have_selector('#divInjectedElement')
  end
end
