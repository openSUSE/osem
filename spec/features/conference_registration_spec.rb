require 'spec_helper'

feature Registration do
  let!(:first_user) { create(:user) } # first user is admin
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
        expect(current_path).to eq(conference_conference_registrations_path(conference.short_title))

        click_link 'Edit your Registration'
        expect(current_path).to eq(edit_conference_conference_registrations_path(conference.short_title))

        click_button 'Update Registration'
        expect(conference.user_registered?(participant)).to be(true)
      end

      context 'unregisters for a conference', feature: true, js: true do
        before do
          visit root_path
          click_link 'My Registration'
        end

        scenario 'deletion of registration is successful' do
          expect(current_path).to eq(conference_conference_registrations_path(conference.short_title))

          click_link 'Unregister'
          expect(conference.user_registered?(participant)).to be(false)
          expect(current_path).to eq root_path
          expect(flash).to eq "You are not registered for #{conference.title} anymore!"
        end

        scenario 'deletion of registration is unsuccessful' do
          allow_any_instance_of(Registration).to receive(:destroy).and_return(false)

          click_link 'Unregister'
          expect(conference.user_registered?(participant)).to be(true)
          expect(current_path).to eq conference_conference_registrations_path(conference.short_title)
          expect(flash).to eq "Could not delete your registration for #{conference.title}: #{registration.errors.full_messages.join('. ')}."
        end
      end
    end

    context 'who is not registered' do
      scenario 'registers for a conference', feature: true, js: true do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registrations_path(conference.short_title))
        click_button 'Register'

        expect(conference.user_registered?(participant)).to be(true)
      end
    end

    context 'registration is closed' do
      let(:conference_with_closed_registration) { create(:conference, registration_period: create(:registration_period)) }

      scenario 'registers for a conference', feature: true do
        visit new_conference_conference_registrations_path(conference_with_closed_registration.short_title)
        expect(current_path).to eq(root_path)
        expect(flash).to eq 'You are not authorized to access this page.'
      end
    end
  end
end
