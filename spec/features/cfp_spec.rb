require 'spec_helper'

feature Conference do

  let!(:conference) { create(:conference) }
  let!(:organizer_role) { create(:organizer_role, resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

  shared_examples 'add and update cfp' do
    scenario 'adds a new cfp', feature: true, js: true do
      expected_count = CallForPaper.count + 1

      sign_in organizer

      visit new_admin_conference_call_for_paper_path(conference.short_title)

      click_button 'Create Call for paper'

      expect(flash).
          to eq('Creating the call for papers failed. ' +
          "Start date can't be blank. End date can't be blank.")

      today = Date.today - 1
      page.execute_script(
      "$('#conference-start-datepicker').val('#{today.strftime('%d/%m/%Y')}')")
      page.execute_script(
      "$('#conference-end-datepicker').val('#{(today + 6).strftime('%d/%m/%Y')}')")

      fill_in 'call_for_paper_rating', with: '4'

      click_button 'Create Call for paper'

      # Validations
      expect(flash).
          to eq('Call for papers successfully created.')
      expect(find('#start_date').text).to eq(today.strftime('%A, %B %-d. %Y'))
      expect(find('#end_date').text).to eq((today + 6).strftime('%A, %B %-d. %Y'))
      expect(find('#rating').text).to eq('4')

      expect(CallForPaper.count).to eq(expected_count)
    end

    scenario 'update cfp', feature: true, js: true do
      conference.call_for_paper = create(:call_for_paper)
      expected_count = CallForPaper.count

      sign_in organizer
      visit admin_conference_call_for_paper_path(conference.short_title)
      click_link 'Edit'

      # Validate update with empty start date will not saved
      page.execute_script(
          "$('#conference-start-datepicker').val('')")
      click_button 'Update Call for paper'
      expect(flash).
          to eq('Updating call for papers failed. ' +
                    "Start date can't be blank.")

      # Fill in date
      today = Date.today - 9
      page.execute_script(
        "$('#conference-start-datepicker').val('#{today.strftime('%d/%m/%Y')}')")
      page.execute_script(
        "$('#conference-end-datepicker').val('#{(today + 14).strftime('%d/%m/%Y')}')")

      fill_in 'call_for_paper_rating', with: '0'
      click_button 'Update Call for paper'

      # Validations
      expect(flash).
          to eq('Call for papers successfully updated.')
      expect(find('#start_date').text).to eq(today.strftime('%A, %B %-d. %Y'))
      expect(find('#end_date').text).to eq((today + 14).strftime('%A, %B %-d. %Y'))
      expect(find('#rating').text).to eq('0')
      expect(CallForPaper.count).to eq(expected_count)
    end
  end

  describe 'organizer' do
    it_behaves_like 'add and update cfp'
  end
end
