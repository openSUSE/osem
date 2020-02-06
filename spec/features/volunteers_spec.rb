# frozen_string_literal: true

require 'spec_helper'

feature Conference do
  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }

  shared_examples 'volunteer' do
    scenario 'adds and updates vdays', feature: true, js: true do
      sign_in(organizer)
      visit admin_conference_volunteers_info_path(
        conference_id: conference.short_title)
      check('Enable Volunteering')
      check('Use vdays')
#       click_link 'Add vday'
#       expect(page.all('div.nested-fields').count == 1).to be true
#       page.
#         find('div.nested-fields:nth-of-type(1) select:nth-of-type(1)').
#         select("#{Date.today.strftime('%Y')}")
#       page.
#         find('div.nested-fields:nth-of-type(1) select:nth-of-type(2)').
#           select("#{Date.today.strftime('%B')}")
#       page.
#         find('div.nested-fields:nth-of-type(1) select:nth-of-type(3)').
#           select("#{Date.today.strftime('%-d')}")
#       page.
#         find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) textarea').
#           set('Example Person')
      click_button 'Update Conference'
      page.find('#flash')
      expect(flash)
      .to eq('Volunteering options were successfully updated.')

#       # Validations
#       expect(find('div.nested-fields:nth-of-type(1) select:nth-of-type(1)').
#         value).to eq("#{Date.today.strftime('%Y')}")
#       expect(find('div.nested-fields:nth-of-type(1) select:nth-of-type(2)').
#         value).to eq("#{Date.today.month}")
#       expect(find('div.nested-fields:nth-of-type(1) select:nth-of-type(3)').
#         value).to eq("#{Date.today.strftime('%-d')}")
#       expect(
#         find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) textarea').
#         value).to eq('Example Person')
#
#       # Remove vday
#       click_link 'Remove vday'
#       expect(page.all('div.nested-fields').count == 0).to be true
      click_button 'Update Conference'
      page.find('#flash')
      expect(flash).to eq('Volunteering options were successfully updated.')
      expect(page.all('div.nested-fields').count == 0).to be true
      sign_out
    end

    scenario 'adds and updates vpositions', feature: true, js: true do
      sign_in(organizer)
      visit admin_conference_volunteers_info_path(
        conference_id: conference.short_title)

      # Adding vday
      check('Enable Volunteering')
      check('Use vdays')
#       click_link 'Add vday'
#       expect(page.all('div.nested-fields').count == 1).to be true
#       page.
#         find('div.nested-fields:nth-of-type(1) select:nth-of-type(1)').
#           select("#{Date.today.strftime('%Y')}")
#       page.
#         find('div.nested-fields:nth-of-type(1) select:nth-of-type(2)').
#         select("#{Date.today.strftime('%B')}")
#       page.
#         find('div.nested-fields:nth-of-type(1) select:nth-of-type(3)').
#         select("#{Date.today.strftime('%-d')}")
#       page.
#         find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) textarea').
#         set('Example Person')
      click_button 'Update Conference'
      page.find('#flash')
      expect(flash)
      .to eq('Volunteering options were successfully updated.')

      # Add vposition
      check('Use vpositions')
#       click_link 'Add vposition'
#       expect(page.all('div.nested-fields').count == 2).to be true
#       page.find('div.vpositions div.nested-fields:nth-of-type(1)'\
#                 ' div:nth-of-type(1) input').
#                     set('Example Position')
#       page.find('div.vpositions div.nested-fields:nth-of-type(1)'\
#                 ' div:nth-of-type(2) textarea').
#                     set('Example Description')
#       find(:css, "select[id^='conference_vpositions_attributes_']"\
#                  "[id$='_vday_ids']").
#                       find(:option, "#{Date.today.strftime}").select_option
      click_button 'Update Conference'
      page.find('#flash')
      expect(flash)
      .to eq('Volunteering options were successfully updated.')

      # Validations
#       expect(find('div.vpositions div.nested-fields:nth-of-type(1)'\
#                   ' div:nth-of-type(1) input').
#                       value).to eq('Example Position')
#       expect(find('div.vpositions div.nested-fields:nth-of-type(1)'\
#                   ' div:nth-of-type(2) textarea').
#                       value).to eq('Example Description')
#
#       expect(find('div.vpositions div.nested-fields:nth-of-type(1)'\
#                   ' div:nth-of-type(3) select:nth-of-type(1)').find('option[selected]').
#                       text).to eq(Date.today.strftime)

      # Remove vposition
#       click_link 'Remove vposition'
#       expect(page.all('div.nested-fields').count == 1).to be true
#       click_button 'Update Conference'
      page.find('#flash')
      expect(flash).to eq('Volunteering options were successfully updated.')
#       click_link 'Remove vday'
#       expect(page.all('div.nested-fields').count == 0).to be true
      sign_out
    end
  end

  describe 'organizer' do
    it_behaves_like 'volunteer', :organizer
  end
end
