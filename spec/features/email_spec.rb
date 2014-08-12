require 'spec_helper'

feature EmailSettings do
  # It is necessary to use bang version of let to build roles before user
  let!(:participant_role) { create(:participant_role) }
  let!(:organizer_conference_1_role) { create(:organizer_conference_1_role) }

  shared_examples 'email settings' do |user|
    scenario 'updates email settings',
             feature: true, js: true do

      conference = create(:conference)
      expected_count = EmailSettings.count

      sign_in create(user)

      visit admin_conference_emails_path(conference.short_title)

      fill_in 'email_settings_registration_subject',
              with: 'Registration subject'
      fill_in 'email_settings_registration_email_template',
              with: 'Registration email body'

      fill_in 'email_settings_accepted_subject',
              with: 'Accepted subject'
      fill_in 'email_settings_accepted_email_template',
              with: 'Accepted email body'

      fill_in 'email_settings_rejected_subject',
              with: 'Rejected subject'
      fill_in 'email_settings_rejected_email_template',
              with: 'Rejected email body'

      fill_in 'email_settings_confirmed_without_registration_subject',
              with: 'Confirmed without registration subject'
      fill_in 'email_settings_confirmed_email_template',
              with: 'Confirmed without registration email body'

      fill_in 'email_settings_updated_conference_dates_subject',
              with: 'Updated conference dates subject'
      fill_in 'email_settings_updated_conference_dates_template',
              with: 'Updated conference dates email template'

      fill_in 'email_settings_updated_conference_registration_dates_subject',
              with: 'Updated conference registration dates subject'
      fill_in 'email_settings_updated_conference_registration_dates_template',
              with: 'Updated conference registration dates template'

      fill_in 'email_settings_venue_update_subject',
              with: 'Updated conference venue subject'
      fill_in 'email_settings_venue_update_template',
              with: 'Updated conference venue template'

      click_button 'Update Email settings'

      expect(flash).
          to eq('Settings have been successfully updated.')

      expect(find('#email_settings_registration_subject').
                 value).to eq('Registration subject')
      expect(find('#email_settings_registration_email_template').
                 value).to eq('Registration email body')
      expect(find('#email_settings_accepted_subject').
                 value).to eq('Accepted subject')
      expect(find('#email_settings_accepted_email_template').
                 value).to eq('Accepted email body')
      expect(find('#email_settings_rejected_subject').
                 value).to eq('Rejected subject')
      expect(find('#email_settings_rejected_email_template').
                 value).to eq('Rejected email body')
      expect(find('#email_settings_confirmed_without_registration_subject').
                 value).to eq('Confirmed without registration subject')
      expect(find('#email_settings_confirmed_email_template').
                 value).to eq('Confirmed without registration email body')
      expect(find('#email_settings_updated_conference_dates_subject').
                 value).to eq('Updated conference dates subject')
      expect(find('#email_settings_updated_conference_dates_template').
                 value).to eq('Updated conference dates email template')
      expect(find('#email_settings_updated_conference_registration_dates_subject').
                 value).to eq('Updated conference registration dates subject')
      expect(find('#email_settings_updated_conference_registration_dates_template').
                 value).to eq('Updated conference registration dates template')
      expect(find('#email_settings_venue_update_subject').
                 value).to eq('Updated conference venue subject')
      expect(find('#email_settings_venue_update_template').
                 value).to eq('Updated conference venue template')

      expect(EmailSettings.count).to eq(expected_count)

    end
  end

  describe 'organizer' do
    it_behaves_like 'email settings', :organizer_conference_1
  end
end
