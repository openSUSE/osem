require 'spec_helper'

feature User do
  let(:user) { create(:user, name: 'My Name', biography: 'This is my biography!') }

  describe 'users#show' do
    let!(:conference) { create(:conference, title: 'My conference') }
    let!(:unconfirmed_event) { create(:event, state: 'unconfirmed', title: 'This is my test event title!', program: conference.program) }

    before :each do
      unconfirmed_event.event_users = [create(:event_user, user: user, event_role: 'submitter')]
    end

    it 'shows user information' do
      visit user_path(user)
      expect(page).to have_content 'My Name'
      expect(page).to have_content 'This is my biography!'
      expect(page).to have_selector('img')
      expect(page).to_not have_content 'My Name presents'
    end

    it 'does not show event information for unconfirmed events' do
      expect(page).to_not have_selector('h3', text: 'My Name presents 1 Event:')
      expect(page).to_not have_selector('ul li h4', text: 'This is my test event title!')
      expect(page).to_not have_selector('ul li h4 strong', text: 'at')
      expect(page).to_not have_selector('ul li h4', text: 'at My conference')
    end

    it 'shows user event information, when user has confirmed events' do
      # User has 3 confirmed events, and 1 unconfirmed
      # 2 confirmed events in one conference, 1 confirmed event in another conference

      event1 = create(:event, state: 'confirmed', title: 'This is my test event title!', program: conference.program)

      event2 = create(:event, state: 'confirmed', title: 'This is my second test event title!', program: conference.program)

      event1.event_users = [create(:event_user, user: user, event_role: 'submitter')]
      event2.event_users = [create(:event_user, user: user, event_role: 'submitter')]

      another_conference = create(:conference, title: 'My another conference')

      another_event = create(:event, state: 'confirmed', title: 'This is my another test event title!', program: another_conference.program)

      another_event.event_users = [create(:event_user, user: user, event_role: 'submitter')]

      visit user_path(user)
      expect(page).to have_selector('h3', text: 'My Name presents 3 Events:', count: 1)
      expect(page).to have_selector('ul li h4', text: 'This is my test event title!', count: 1)
      expect(page).to have_selector('ul li h4 strong', text: 'at', count: 3)
      expect(page).to have_selector('ul li h4', text: 'at My conference', count: 2)
      expect(page).to have_selector('ul li h4', text: 'This is my second test event title!', count: 1)
      expect(page).to have_selector('ul li h4', text: 'This is my another test event title!', count: 1)
      expect(page).to have_selector('ul li h4', text: 'at My another conference', count: 1)
    end
  end
end
