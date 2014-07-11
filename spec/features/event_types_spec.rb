require 'spec_helper'

feature EventType do
  # It is necessary to use bang version of let to build roles before user
  let!(:participant_role) { create(:participant_role) }
  let!(:organizer_role) { create(:organizer_role) }

  shared_examples 'event types' do |user|
    scenario 'adds and updates event type', feature: true, js: true do
      conference = create(:conference)
      sign_in create(user)
      visit admin_conference_event_types_path(
                conference_id: conference.short_title)

      expect(page.all('div.nested-fields').count == 2).to be true 
      # Add event type
      click_link 'Add event_type'
      expect(page.all('div.nested-fields').count == 3).to be true

      page.
          find('div.nested-fields:nth-of-type(3) div:nth-of-type(1) input').
          set('Example event type')
      page.
          find('div.nested-fields:nth-of-type(3) div:nth-of-type(2) input').
          set('60')
      page.
          find('div.nested-fields:nth-of-type(3) div:nth-of-type(3) input').
          set('0')
      page.
          find('div.nested-fields:nth-of-type(3) div:nth-of-type(4) input').
          set('300')

      click_button 'Update Conference'

      # Validations
      expect(flash).to eq('Event types were successfully updated.')
      expect(find('div.nested-fields:nth-of-type(3) div:nth-of-type(1) input').
                 value).to eq('Example event type')
      expect(find('div.nested-fields:nth-of-type(3) div:nth-of-type(2) input').
                 value).to eq('60')
      expect(find('div.nested-fields:nth-of-type(3) div:nth-of-type(3) input').
                 value).to eq('0')
      expect(find('div.nested-fields:nth-of-type(3) div:nth-of-type(4) input').
                 value).to eq('300')

      # Remove event type
      within("div.nested-fields:nth-of-type(3)") do
	click_link 'Remove event_type'
      end
      expect(page.all('div.nested-fields').count == 2).to be true
      click_button 'Update Conference'
      expect(flash).to eq('Event types were successfully updated.')
      expect(page.all('div.nested-fields').count == 2).to be true
    end
  end

  describe 'organizer' do
    it_behaves_like 'event types', :organizer
  end
end
