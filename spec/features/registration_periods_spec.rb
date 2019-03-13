# frozen_string_literal: true

require 'spec_helper'

feature RegistrationPeriod do
  # It is necessary to use bang version of let to build roles before user
  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, email: 'admin@example.com', resource: conference) }
  let(:start_date) { Date.today }
  let(:end_date) { Date.today + 5 }

  context 'as organizer' do
    before do
      sign_in organizer
      visit admin_conference_registration_period_path(conference_id: conference)
      click_link 'New Registration Period'
    end

    scenario 'requires start date and end date', feature: true do
      visit admin_conference_registration_period_path(conference_id: conference)
      click_link 'New Registration Period'

      click_button 'Save Registration Period'
      page.find('#flash')
      expect(flash)
          .to eq('An error prohibited the Registration Period from being saved: ' \
          "Start date can't be blank. End date can't be blank.")
    end

    context 'with tickets' do
      let!(:registration_ticket) do
        create(:registration_ticket, conference: conference)
      end

      it 'creates registration period', feature: true, js: true do
        page
            .execute_script("$('#registration-period-start-datepicker').val('" +
                               "#{start_date.strftime('%d/%m/%Y')}')")
        page
            .execute_script("$('#registration-period-end-datepicker').val('" +
                               "#{end_date.strftime('%d/%m/%Y')}')")

        click_button 'Save Registration Period'
        page.find('#flash')
        expect(flash).to eq('Registration Period successfully updated.')
        expect(current_path).to eq(admin_conference_registration_period_path(conference.short_title))
        expect(page).to have_text("Ticket required?\nYes")

        registration_period = RegistrationPeriod.where(conference_id: conference.id).first
        registration_period.reload
        expect(registration_period.start_date).to eq(start_date)
        expect(registration_period.end_date).to eq(end_date)
      end
    end

    context 'without tickets' do
      it 'creates registration period', feature: true, js: true do
        page
            .execute_script("$('#registration-period-start-datepicker').val('" +
                               "#{start_date.strftime('%d/%m/%Y')}')")
        page
            .execute_script("$('#registration-period-end-datepicker').val('" +
                               "#{end_date.strftime('%d/%m/%Y')}')")

        click_button 'Save Registration Period'
        page.find('#flash')
        expect(flash).to eq('Registration Period successfully updated.')
        expect(current_path).to eq(admin_conference_registration_period_path(conference.short_title))
        expect(page).to have_text("Ticket required?\nNo")

        registration_period = RegistrationPeriod.where(conference_id: conference.id).first
        registration_period.reload
        expect(registration_period.start_date).to eq(start_date)
        expect(registration_period.end_date).to eq(end_date)
      end
    end
  end
end
