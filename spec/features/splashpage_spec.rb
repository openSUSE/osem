require 'spec_helper'

feature Splashpage do

  # It is necessary to use bang version of let to build roles before user
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { create(:organizer_role, resource: conference) }
  let!(:organizer) { create(:user, email: 'admin@example.com', role_ids: [organizer_role.id]) }
  let!(:participant) { create(:user, biography: '') }

  scenario 'create a valid splashpage', js: true do
    sign_in organizer
    visit admin_conference_splashpage_path(conference.short_title)

    click_link 'Create Splashpage'

    fill_in 'splashpage_banner_description', with: 'banner description'
    fill_in 'splashpage_ticket_description', with: 'ticket description'
    fill_in 'splashpage_sponsor_description', with: 'sponsor description'
    fill_in 'splashpage_registration_description', with: 'registration description'
    fill_in 'splashpage_lodging_description', with: 'lodging description'

    click_button 'Save Splashpage'

    expect(flash).to eq('Splashpage successfully created.')
    expect(current_path).to eq(admin_conference_splashpage_path(conference.short_title))

    splashpage = Splashpage.find_by(conference_id: conference.id)
    splashpage.reload
    expect(splashpage.banner_description).to eq('banner description')
    expect(splashpage.ticket_description).to eq('ticket description')
    expect(splashpage.sponsor_description).to eq('sponsor description')
    expect(splashpage.registration_description).to eq('registration description')
    expect(splashpage.lodging_description).to eq('lodging description')
  end

  context 'splashpage already created' do
    # before(:each) do
    #   @splashpage = create(:splashpage)
    #   conference.splashpage = @splashpage
    # end
    #
    let!(:splashpage) { create(:splashpage, conference: conference, public: false)}

    scenario 'update a valid splashpage', js: true do
      sign_in organizer
      visit admin_conference_splashpage_path(conference.short_title)

      click_link 'Edit'

      fill_in 'splashpage_banner_description', with: 'banner description'
      fill_in 'splashpage_ticket_description', with: 'ticket description'
      fill_in 'splashpage_sponsor_description', with: 'sponsor description'
      fill_in 'splashpage_registration_description', with: 'registration description'
      fill_in 'splashpage_lodging_description', with: 'lodging description'

      click_button 'Save Splashpage'

      expect(flash).to eq('Splashpage successfully updated.')
      expect(current_path).to eq(admin_conference_splashpage_path(conference.short_title))

      splashpage.reload
      expect(splashpage.banner_description).to eq('banner description')
      expect(splashpage.ticket_description).to eq('ticket description')
      expect(splashpage.sponsor_description).to eq('sponsor description')
      expect(splashpage.registration_description).to eq('registration description')
      expect(splashpage.lodging_description).to eq('lodging description')
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
