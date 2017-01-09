require 'spec_helper'

describe 'proposals/show' do
  let!(:conference) { create(:conference) }
  let!(:event) { create(:event_xss, program: conference.program, title: 'event1', language: 'English') }
  let(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let(:organizer) { create(:user, name: 'test name', email: 'test@email.osem', role_ids: [organizer_role.id]) }

  it 'renders proposal information' do
    sign_in organizer

    assign :conference, conference
    assign :event, event
    assign :speaker, organizer

    render template: 'proposals/show.html.haml'

    expect(rendered).to_not have_selector('#divInjectedElement')
  end
end
