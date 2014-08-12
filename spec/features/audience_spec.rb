require 'spec_helper'

feature Audience do

  # It is necessary to use bang version of let to build roles before user
  let!(:organizer_role) { create(:organizer_role) }
  let!(:participant_role) { create(:participant_role) }
  let!(:admin_role) { create(:admin_role) }

  shared_examples 'audience' do |user|
    scenario 'updates audience', js: true do
      conference = create(:conference)
      audience = create(:audience)
      conference.audience = audience

      sign_in create(user)
      visit edit_admin_conference_audience_path(
                conference_id: conference.short_title)

      page.
          execute_script("$('#registration-start-datepicker').val('" +
                             "#{Date.today.strftime('%d/%m/%Y')}')")
      page.
          execute_script("$('#registration-end-datepicker').val('" +
                             "#{(Date.today + 7).strftime('%d/%m/%Y')}')")
      fill_in 'audience_registration_description', with: 'audience registration description'

      click_button 'Save Audience'

      expect(flash).to eq('Audience was successfully updated.')

      audience.reload
      expect(audience.registration_start_date).to eq(Date.today)
      expect(audience.registration_end_date).to eq(Date.today + 7)
      expect(audience.registration_description).to eq('audience registration description')
    end
  end

  describe 'admin' do
    it_behaves_like 'audience', :admin
  end

  describe 'organizer' do
    it_behaves_like 'audience', :organizer
  end
end
