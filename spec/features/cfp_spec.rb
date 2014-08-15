require 'spec_helper'

feature Conference do

  let!(:conference) { create(:conference) }
  let!(:organizer_role) { create(:organizer_role, resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

  shared_examples 'add and update cfp' do
    scenario 'adds a new cfp', feature: true, js: true do
      expected_count = CallForPapers.count + 1

      sign_in organizer

      visit admin_conference_callforpapers_path(conference.short_title)

      click_button 'Create Call for papers'

      expect(flash).
          to eq('Creating the call for papers failed. ' +
          "Start date can't be blank. End date can't be blank.")

      today = Date.today - 1
      page.execute_script(
      "$('#conference-start-datepicker').val('#{today.strftime('%d/%m/%Y')}')")
      page.execute_script(
      "$('#conference-end-datepicker').val('#{(today + 7).strftime('%d/%m/%Y')}')")

      fill_in 'call_for_papers_description', with: 'Cfp description'
      fill_in 'call_for_papers_rating', with: '4'

      click_button 'Create Call for papers'

      # Validations
      expect(flash).
          to eq('Call for Papers was successfully created.')
      expect(find('#conference-start-datepicker').value).
          to eq(today.strftime('%Y-%m-%d'))
      expect(find('#conference-end-datepicker').value).
          to eq((today + 7).strftime('%Y-%m-%d'))
      expect(find('#call_for_papers_description').text).
          to eq('Cfp description')
      expect(find('#call_for_papers_rating').value).to eq('4')

      expect(CallForPapers.count).to eq(expected_count)
    end

    scenario 'update cfp', feature: true, js: true do
      conference.call_for_papers = create(:call_for_papers)
      expected_count = CallForPapers.count

      sign_in organizer
      visit admin_conference_callforpapers_path(conference.short_title)

      # Validate update with empty start date will not saved
      page.execute_script(
          "$('#conference-start-datepicker').val('')")
      click_button 'Update Call for papers'
      expect(flash).
          to eq('Updating call for papers failed. ' +
                    "Start date can't be blank.")

      # Fill in date
      today = Date.today - 7
      page.execute_script(
        "$('#conference-start-datepicker').val('#{today.strftime('%d/%m/%Y')}')")
      page.execute_script(
        "$('#conference-end-datepicker').val('#{(today + 14).strftime('%d/%m/%Y')}')")

      fill_in 'call_for_papers_description', with: 'Updated description'
      fill_in 'call_for_papers_rating', with: '0'
      click_button 'Update Call for papers'

      # Validations
      expect(flash).
          to eq('Call for Papers was successfully updated.')
      expect(find('#conference-start-datepicker').value).
          to eq(today.strftime('%Y-%m-%d'))
      expect(find('#conference-end-datepicker').value).
          to eq((today + 14).strftime('%Y-%m-%d'))
      expect(find('#call_for_papers_description').text).
          to eq('Updated description')
      expect(find('#call_for_papers_rating').value).to eq('0')
      expect(CallForPapers.count).to eq(expected_count)
    end
  end

  describe 'organizer' do
    it_behaves_like 'add and update cfp'
  end
end
