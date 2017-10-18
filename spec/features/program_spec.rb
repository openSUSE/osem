require 'spec_helper'

feature Program do

  let!(:conference) { create(:conference) }
  let!(:program) { conference.program }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

  describe 'edit program' do
    before :each do
      sign_in organizer
    end

    scenario 'changes rating', feature: true, js: true do
      visit admin_conference_program_path(conference.short_title)

      click_link 'Edit'

      fill_in 'program_rating', with: '4'

      click_button 'Update Program'

      # Validations
      expect(flash)
          .to eq('The program was successfully updated.')
      expect(find('#rating').text).to eq('4')
    end
  end
end
