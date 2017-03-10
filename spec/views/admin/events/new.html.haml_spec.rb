require 'spec_helper'

describe 'admin/conferences/events/new' do
  it 'renders the new event template' do
    @conference = create(:conference)
    @user = create(:user)
    @program = @conference.program
    @event = build(:event, program: @conference.program)
    @event_type = create(:event_type, program: @program)
    @url = admin_conference_program_events_path(@conference.short_title, @event)
    @users = User.all
    render template: 'admin/events/_form.html.haml'
    expect(rendered).to include('New Event')
  end
end
