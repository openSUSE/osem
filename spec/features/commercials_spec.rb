# frozen_string_literal: true

require 'spec_helper'

feature Commercial do
  # It is necessary to use bang version of let to build roles before user
  let!(:conference) { create(:conference) }
  let!(:cfp) { create(:cfp, program: conference.program) }
  let!(:organizer) { create(:organizer, resource: conference) }
  let!(:participant) { create(:user) }
  let!(:event) { create(:event, program: conference.program, title: 'Example Proposal') }
  let!(:event_user) do
    create(:event_user, user: participant, event: event, event_role: 'submitter')
  end

  before(:each) do
    sign_in participant
  end

  scenario 'adds a valid commercial of an event', feature: true, js: true do
    visit edit_conference_program_proposal_path(conference.short_title, event.id)
    click_link 'Commercials'
    fill_in 'commercial_url', with: 'https://www.youtube.com/watch?v=M9bq_alk-sw'

    # Workaround to enable the 'Create Commercial' button
    page.execute_script("$('#commercial_submit_action').prop('disabled', false)")

    click_button 'Create Commercial'
    page.find('#flash')
    expect(flash).to eq('Commercial was successfully created.')
  end

  scenario 'updates a commercial of an event', feature: true, js: true do
    commercial = create(:commercial,
                        commercialable_id:   event.id,
                        commercialable_type: 'Event')
    visit edit_conference_program_proposal_path(conference.short_title, event.id)
    click_link 'Commercials'
    within('.thumbnail') do
      fill_in 'commercial_url', with: 'https://www.youtube.com/watch?v=M9bq_alk-sw'
      # Workaround to enable the 'Create Commercial' button
      page.execute_script("$('#commercial_submit_action').prop('disabled', false)")
      click_button 'Update Commercial'
    end
    page.find('#flash')
    expect(flash).to eq('Commercial was successfully updated.')
    expect(event.commercials.count).to eq(1)
    commercial.reload
    expect(commercial.url).to eq('https://www.youtube.com/watch?v=M9bq_alk-sw')
  end

  scenario 'deletes a commercial of an event', feature: true, js: true do
    create(:commercial,
           commercialable_id:   event.id,
           commercialable_type: 'Event')
    visit edit_conference_program_proposal_path(conference.short_title, event.id)
    click_link 'Commercials'
    page.accept_alert do
      click_link 'Delete'
    end
    page.find('#flash')
    expect(flash).to eq('Commercial was successfully destroyed.')
    expect(event.commercials.count).to eq(0)
  end
end
