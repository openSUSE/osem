# frozen_string_literal: true

require 'spec_helper'

feature 'Version' do
  let!(:conference) { create(:conference) }
  let!(:cfp) { create(:cfp, program: conference.program) }
  let!(:organizer) { create(:organizer, resource: conference) }
  let(:event_with_commercial) { create(:event, program: conference.program) }
  let(:event_commercial) { create(:event_commercial, commercialable: event_with_commercial, url: 'https://www.youtube.com/watch?v=M9bq_alk-sw') }

  before(:each) do
    sign_in organizer
  end

  scenario 'displays changes', feature: true, versioning: true, js: true do
    visit edit_admin_conference_contact_path(conference.short_title)
    fill_in 'contact_email', with: 'example@example.com'
    fill_in 'contact_sponsor_email', with: 'sponsor@example.com'
    fill_in 'contact_social_tag', with: 'example'
    fill_in 'contact_googleplus', with: 'http:\\www.google.com'
    click_button 'Update Contact'

    visit admin_revision_history_path
    expect(page).to have_text("#{organizer.name} updated social tag, email, googleplus and sponsor email of contact details in conference #{conference.short_title}")
  end
end
