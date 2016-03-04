require 'spec_helper'

feature Splashpage do

  # It is necessary to use bang version of let to build roles before user
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, email: 'admin@example.com', role_ids: [organizer_role.id]) }
  let!(:participant) { create(:user, biography: '', is_admin: false) }

  scenario 'create a valid splashpage', js: true do
    sign_in organizer
    visit admin_conference_splashpage_path(conference.short_title)

    click_link 'Create Splashpage'
    click_button 'Save Splashpage'

    expect(flash).to eq('Splashpage successfully created.')
    expect(current_path).to eq(admin_conference_splashpage_path(conference.short_title))
  end

  context 'splashpage already created' do
    let!(:splashpage) { create(:splashpage, conference: conference, public: false)}

    scenario 'update a valid splashpage', js: true do
      sign_in organizer
      visit admin_conference_splashpage_path(conference.short_title)

      click_link 'Edit'
      check('Make splash page public')
      click_button 'Save Splashpage'

      expect(flash).to eq('Splashpage successfully updated.')
      expect(current_path).to eq(admin_conference_splashpage_path(conference.short_title))

      click_link 'Edit'
      expect(page.has_checked_field?('Make splash page public?')).to be true
    end

    scenario 'delete the splashpage', js: true do
      sign_in organizer
      visit admin_conference_splashpage_path(conference.short_title)
      click_link 'Delete'

      expect(current_path).to eq(admin_conference_splashpage_path(conference.short_title))
      expect(flash).to eq('Splashpage was successfully destroyed.')
      expect(Splashpage.count).to eq(0)
    end

    scenario 'splashpage is accessible for organizers if it is not public' do
      sign_in organizer
      visit conference_path(conference.short_title)
      expect(current_path).to eq(conference_path(conference.short_title))
    end

    scenario 'splashpage is not accessible for participants if it is not public' do
      sign_in participant
      visit conference_path(conference.short_title)

      expect(flash).to eq('You are not authorized to access this page.')
      expect(current_path).to eq(root_path)
    end
  end
end
