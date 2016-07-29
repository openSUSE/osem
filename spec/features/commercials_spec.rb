require 'spec_helper'

feature Commercial do
  # It is necessary to use bang version of let to build roles before user
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }
  let!(:participant) { create(:user) }

  context 'in admin area' do
    scenario 'adds, updates, deletes of a conference', feature: true, js: true do
      expected_count = conference.commercials.count + 1

      sign_in organizer

      visit admin_conference_commercials_path(conference.short_title)

      # Workaround to enable the 'Create Commercial' button
      page.execute_script("$('#commercial_submit_action').prop('disabled', false)")

      # Create valid commercial
      fill_in 'commercial_url', with: 'https://www.youtube.com/watch?v=M9bq_alk-sw'
      click_button 'Create Commercial'
      expect(flash).to eq('Commercial was successfully created.')
      expect(conference.commercials.count).to eq(expected_count)

      commercial = conference.commercials.where(url: 'https://www.youtube.com/watch?v=M9bq_alk-sw').first
      fill_in "commercial_url_#{commercial.id}", with: 'https://www.youtube.com/watch?v=VNkDJk5_9eU'
      click_button 'Update'

      expect(flash).to eq('Commercial was successfully updated.')
      expect(conference.commercials.count).to eq(expected_count)
      commercial.reload
      expect(commercial.url).to eq 'https://www.youtube.com/watch?v=VNkDJk5_9eU'

      # Delete commercial
      click_link 'Delete'

      expect(flash).to eq('Commercial was successfully destroyed.')
      expect(conference.commercials.count).to eq(expected_count - 1)
    end
  end

  context 'in public area' do
    let!(:event) { create(:event, program: conference.program, title: 'Example Proposal') }

    before(:each) do
      event.event_users = [create(:event_user,
                                  user_id: participant.id,
                                  event_id: event.id,
                                  event_role: 'submitter')]

      @expected_count = Commercial.count + 1
      sign_in participant
    end

    after(:each) do
      sign_out
    end

    scenario 'adds a valid commercial of an event', feature: true, versioning: true, js: true do
      visit edit_conference_program_proposal_path(conference.short_title, event.id)
      click_link 'Commercials'
      fill_in 'commercial_url', with: 'https://www.youtube.com/watch?v=M9bq_alk-sw'

      # Workaround to enable the 'Create Commercial' button
      page.execute_script("$('#commercial_submit_action').prop('disabled', false)")

      click_button 'Create Commercial'
      expect(flash).to eq('Commercial was successfully created.')
      expect(event.commercials.count).to eq(@expected_count)
    end

    scenario 'does not add an invalid commercial of an event', feature: true, js: true do
      visit edit_conference_program_proposal_path(conference.short_title, event.id)
      click_link 'Commercials'
      fill_in 'commercial_url', with: 'invalid_commercial_url'

      # Workaround to enable the 'Create Commercial' button
      page.execute_script("$('#commercial_submit_action').prop('disabled', false)")

      click_button 'Create Commercial'
      expect(flash).to include('An error prohibited this Commercial from being saved:')
      expect(current_path).to eq edit_conference_program_proposal_path(conference.short_title, event.id)
      expect(event.commercials.count).to eq 0
    end

    scenario 'updates a commercial of an event', feature: true, versioning: true, js: true do
      commercial = create(:commercial,
                          commercialable_id: event.id,
                          commercialable_type: 'Event')
      visit edit_conference_program_proposal_path(conference.short_title, event.id)
      click_link 'Commercials'
      fill_in "commercial_url_#{commercial.id}", with: 'https://www.youtube.com/watch?v=M9bq_alk-sw'
      click_button 'Update'
      expect(flash).to eq('Commercial was successfully updated.')
      expect(event.commercials.count).to eq(@expected_count)
      commercial.reload
      expect(commercial.url).to eq('https://www.youtube.com/watch?v=M9bq_alk-sw')
    end

    scenario 'does not update a commercial of an event with invalid data', feature: true, versioning: true, js: true do
      commercial = create(:commercial,
                          commercialable_id: event.id,
                          commercialable_type: 'Event')
      visit edit_conference_program_proposal_path(conference.short_title, event.id)
      click_link 'Commercials'
      fill_in "commercial_url_#{commercial.id}", with: 'invalid_commercial_url'
      click_button 'Update'
      expect(flash).to include('An error prohibited this Commercial from being saved:')
      expect(current_path).to eq edit_conference_program_proposal_path(conference.short_title, event.id)
      commercial.reload
      expect(commercial.url).to eq('https://www.youtube.com/watch?v=BTTygyxuGj8')
    end

    scenario 'deletes a commercial of an event', feature: true, versioning: true, js: true do
      create(:commercial,
             commercialable_id: event.id,
             commercialable_type: 'Event')
      visit edit_conference_program_proposal_path(conference.short_title, event.id)
      click_link 'Commercials'
      click_link 'Delete'
      page.driver.network_traffic
      expect(flash).to eq('Commercial was successfully destroyed.')
      expect(event.commercials.count).to eq(@expected_count - 1)
    end
  end
end
