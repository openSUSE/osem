require 'spec_helper'

feature RegistrationPeriod do

  # It is necessary to use bang version of let to build roles before user
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, email: 'admin@example.com', role_ids: [organizer_role.id]) }

  shared_examples 'successfully' do
    scenario 'create and update registration period', js: true do
      sign_in organizer
      visit admin_conference_registration_period_path(
                conference_id: conference.short_title)

      click_link 'New Registration Period'

      click_button 'Save Registration Period'
      expect(flash)
          .to eq('An error prohibited the Registration Period from being saved: ' \
          "Start date can't be blank. End date can't be blank.")

      page
          .execute_script("$('#registration-period-start-datepicker').val('" +
                             "#{Date.today.strftime('%d/%m/%Y')}')")
      page
          .execute_script("$('#registration-period-end-datepicker').val('" +
                             "#{(Date.today + 5).strftime('%d/%m/%Y')}')")

      click_button 'Save Registration Period'

      expect(flash).to eq('Registration Period successfully updated.')
      expect(current_path).to eq(admin_conference_registration_period_path(conference.short_title))

      registration_period = RegistrationPeriod.where(conference_id: conference.id).first
      registration_period.reload
      expect(registration_period.start_date).to eq(Date.today)
      expect(registration_period.end_date).to eq(Date.today + 5)
    end
  end

  describe 'organizer' do
    it_behaves_like 'successfully'
  end
end
