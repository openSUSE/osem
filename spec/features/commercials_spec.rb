# frozen_string_literal: true

require 'spec_helper'

feature Commercial do
  # It is necessary to use bang version of let to build roles before user
  let!(:conference) { create(:conference) }
  let!(:cfp) { create(:cfp, program: conference.program) }
  let!(:organizer) { create(:organizer, resource: conference) }
  let!(:participant) { create(:user) }

  context 'in admin area' do
    scenario 'adds, updates, deletes of a conference', feature: true, js: true do
      sign_in organizer

      visit admin_conference_commercials_path(conference.short_title)

      # Create valid commercial
      fill_in 'commercial_url', with: 'https://www.youtube.com/watch?v=M9bq_alk-sw'
      click_button 'Save Materials'
      page.find('#flash')
      expect(flash).to eq('Materials were successfully created.')
      page.find('#flash .button.close').click
      expect(conference.commercials.count).to eq(1)

      commercial = conference.commercials.where(url: 'https://www.youtube.com/watch?v=M9bq_alk-sw').first

      fill_in "commercial_url_#{commercial.id}", with: 'https://www.youtube.com/watch?v=VNkDJk5_9eU'
      click_button 'Update'
      page.find('#flash')
      expect(flash).to eq('Materials were successfully updated.')
      page.find('#flash .button.close').click
      expect(conference.commercials.count).to eq(1)
      commercial.reload
      expect(commercial.url).to eq 'https://www.youtube.com/watch?v=VNkDJk5_9eU'

      # Delete commercial
      page.accept_alert do
        click_link 'Delete'
      end
      page.find('#flash')
      expect(flash).to eq('Materials were successfully destroyed.')
      expect(conference.commercials.count).to eq(0)
    end
  end

  context 'in public area' do
    let!(:event) { create(:event, program: conference.program, title: 'Example Proposal') }
    let!(:event_user) do
      create(:event_user, user: participant, event: event, event_role: 'submitter')
    end

    before(:each) do
      sign_in participant
    end

    scenario 'adds a valid commercial of an event', feature: true, js: true do
      visit edit_conference_program_proposal_path(conference.short_title, event.id)
      click_link 'Materials'
      fill_in 'commercial_url', with: 'https://www.youtube.com/watch?v=M9bq_alk-sw'

      # Workaround to enable the 'Save Materials' button
      page.execute_script("$('#commercial_submit_action').prop('disabled', false)")

      click_button 'Save Materials'
      page.find('#flash')
      expect(flash).to eq('Materials were successfully created.')
    end

    scenario 'does not add an invalid commercial of an event', feature: true, js: true do
      visit edit_conference_program_proposal_path(conference.short_title, event.id)
      click_link 'Materials'
      fill_in 'commercial_url', with: 'invalid_commercial_url'
      expect(page).to have_content('No embeddable content')
      expect(page).to have_css("button[type='submit']:disabled", text: 'Save Materials')
    end

    scenario 'updates materials of an event', feature: true, js: true do
      commercial = create(:commercial,
                          commercialable_id:   event.id,
                          commercialable_type: 'Event')
      visit edit_conference_program_proposal_path(conference.short_title, event.id)
      click_link 'Materials'
      fill_in "commercial_url_#{commercial.id}", with: 'https://www.youtube.com/watch?v=M9bq_alk-sw'
      click_button 'Update'
      page.find('#flash')
      expect(flash).to eq('Materials were successfully updated.')
      expect(event.commercials.count).to eq(1)
      commercial.reload
      expect(commercial.url).to eq('https://www.youtube.com/watch?v=M9bq_alk-sw')
    end

    scenario 'does not update a commercial of an event with invalid data', feature: true do
      commercial = create(:commercial,
                          commercialable_id:   event.id,
                          commercialable_type: 'Event',
                          url:                 'https://www.youtube.com/watch?v=BTTygyxuGj8')
      visit edit_conference_program_proposal_path(conference.short_title, event.id)
      click_link 'Materials'
      fill_in "commercial_url_#{commercial.id}", with: 'invalid_commercial_url'
      click_button 'Update'
      find('#flash')
      expect(current_path).to eq edit_conference_program_proposal_path(conference.short_title, event.id)
      expect(flash).to include('An error prohibited materials from being saved:')
      commercial.reload
      expect(commercial.url).to eq('https://www.youtube.com/watch?v=BTTygyxuGj8')
    end

    scenario 'deletes a commercial of an event', feature: true, js: true do
      create(:commercial,
             commercialable_id:   event.id,
             commercialable_type: 'Event')
      visit edit_conference_program_proposal_path(conference.short_title, event.id)
      click_link 'Materials'
      page.accept_alert do
        click_link 'Delete'
      end
      page.find('#flash')
      expect(flash).to eq('Materials successfully destroyed.')
      expect(event.commercials.count).to eq(0)
    end
  end
end
