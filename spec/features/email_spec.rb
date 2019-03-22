# frozen_string_literal: true

require 'spec_helper'

feature EmailSettings do
  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }

  shared_examples 'email settings' do
    scenario 'updates email settings',
             feature: true, js: true do

      expected_count = EmailSettings.count

      sign_in organizer

      visit admin_conference_emails_path(conference.short_title)
      click_link 'Onboarding'
      fill_in 'email_settings_registration_subject',
              with: 'Registration subject'
      fill_in 'email_settings_registration_body',
              with: 'Registration email body'
      click_link 'Proposal'
      fill_in 'email_settings_accepted_subject',
              with: 'Accepted subject'
      fill_in 'email_settings_accepted_body',
              with: 'Accepted email body'

      fill_in 'email_settings_rejected_subject',
              with: 'Rejected subject'
      fill_in 'email_settings_rejected_body',
              with: 'Rejected email body'

      fill_in 'email_settings_confirmed_without_registration_subject',
              with: 'Confirmed without registration subject'
      fill_in 'email_settings_confirmed_without_registration_body',
              with: 'Confirmed without registration email body'

      page.execute_script 'window.scrollTo(0,0)'
      click_link 'Update Notifications'
      fill_in 'email_settings_conference_dates_updated_subject',
              with: 'Updated conference dates subject'
      fill_in 'email_settings_conference_dates_updated_body',
              with: 'Updated conference dates email template'

      fill_in 'email_settings_conference_registration_dates_updated_subject',
              with: 'Updated conference registration dates subject'
      fill_in 'email_settings_conference_registration_dates_updated_body',
              with: 'Updated conference registration dates template'

      fill_in 'email_settings_venue_updated_subject',
              with: 'Updated conference venue subject'
      fill_in 'email_settings_venue_updated_body',
              with: 'Updated conference venue template'

      click_button 'Update Email settings'
      page.find('#flash')
      expect(flash)
          .to eq('Email settings have been successfully updated.')

      expect(find('#email_settings_registration_subject')
                 .value).to eq('Registration subject')
      expect(find('#email_settings_registration_body')
                 .value).to eq('Registration email body')
      click_link 'Proposal'
      expect(find('#email_settings_accepted_subject')
                 .value).to eq('Accepted subject')
      expect(find('#email_settings_accepted_body')
                 .value).to eq('Accepted email body')
      expect(find('#email_settings_rejected_subject')
                 .value).to eq('Rejected subject')
      expect(find('#email_settings_rejected_body')
                 .value).to eq('Rejected email body')
      expect(find('#email_settings_confirmed_without_registration_subject')
                 .value).to eq('Confirmed without registration subject')
      expect(find('#email_settings_confirmed_without_registration_body')
                 .value).to eq('Confirmed without registration email body')
      click_link 'Update Notifications'
      expect(find('#email_settings_conference_dates_updated_subject')
                 .value).to eq('Updated conference dates subject')
      expect(find('#email_settings_conference_dates_updated_body')
                 .value).to eq('Updated conference dates email template')
      expect(find('#email_settings_conference_registration_dates_updated_subject')
                 .value).to eq('Updated conference registration dates subject')
      expect(find('#email_settings_conference_registration_dates_updated_body')
                 .value).to eq('Updated conference registration dates template')
      expect(find('#email_settings_venue_updated_subject')
                 .value).to eq('Updated conference venue subject')
      expect(find('#email_settings_venue_updated_body')
                 .value).to eq('Updated conference venue template')

      expect(EmailSettings.count).to eq(expected_count)

    end
  end

  describe 'organizer' do
    it_behaves_like 'email settings'
  end
end
