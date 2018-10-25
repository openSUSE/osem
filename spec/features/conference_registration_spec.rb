# frozen_string_literal: true

require 'spec_helper'

feature Registration do
  let!(:conference) { create(:conference, registration_period: create(:registration_period, start_date: 3.days.ago)) }
  let!(:participant) { create(:user) }

  context 'as a participant' do
    before(:each) do
      sign_in participant
    end

    after(:each) do
      sign_out
    end

    context 'who is already registered' do
      let!(:registration) { create(:registration, user: participant, conference: conference) }

      scenario 'updates conference registration', feature: true, js: true do
        visit root_path
        click_link 'My Registration'
        expect(current_path).to eq(conference_conference_registration_path(conference.short_title))

        click_link 'Edit your Registration'
        expect(current_path).to eq(edit_conference_conference_registration_path(conference.short_title))

        click_button 'Update Registration'
        expect(conference.user_registered?(participant)).to be(true)
      end

      scenario 'unregisters for a conference', feature: true, js: true do
        visit root_path
        click_link 'My Registration'
        expect(current_path).to eq(conference_conference_registration_path(conference.short_title))

        page.accept_alert do
          click_link 'Unregister'
        end
        page.find('#flash')
        expect(page).to have_content('not registered')
        expect(conference.user_registered?(participant)).to be(false)
      end
    end

    context 'who is not registered' do
      scenario 'registers for a conference', feature: true, js: true do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        expect(conference.user_registered?(participant)).to be(true)
      end
    end
  end
end
