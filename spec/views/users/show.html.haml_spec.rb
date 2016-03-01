require 'spec_helper'

describe 'users/show.html.haml' do
  before(:each) do
    @user = create(:user, biography: 'This is a test biography for the user.')
    assign :user, @user
    render
  end

  it 'renders user details' do
    expect(rendered).to match(/#{@user.name}/)
  end

  it 'renders confirmed submitted talks, if any' do
    conference = create(:conference, title: 'This is my conference title')
    event = create(:event, title: 'My proposal talk', program: conference.program, state: 'confirmed')
    event.event_users = [create(:event_user, user: @user, event_role: 'submitter')]
    render

    expect(@user.events.confirmed.count).to eq 1
    expect(rendered).to have_content('My proposal talk')
    expect(rendered).to have_content('at This is my conference title')
  end

  it 'does not render submitted talks that are not confirmed' do
    conference = create(:conference, title: 'This is my conference title')
    event = create(:event, title: 'My proposal talk', program: conference.program)
    event.event_users = [create(:event_user, user: @user, event_role: 'submitter')]

    expect(rendered).to_not have_content('My proposal talk')
    expect(rendered).to_not have_content('at This is my conference title')
  end
end
