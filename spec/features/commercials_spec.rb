require 'spec_helper'

feature Commercial do
  # It is necessary to use bang version of let to build roles before user
  let!(:organizer_role) { create(:organizer_role) }
  let!(:participant_role) { create(:participant_role) }
  let!(:admin_role) { create(:admin_role) }

  shared_examples 'adds and updates a commercial' do |user|
    scenario 'of a conference',
             feature: true, js: true do

      conference = create(:conference)
      expected_count = conference.commercials.count + 1

      sign_in create(user)

      visit admin_conference_commercials_path(conference.short_title)

      click_link 'New Commercial'

      # Create without an commercial id
      select('SlideShare', from: 'commercial_commercial_type')

      click_button 'Create Commercial'
      expect(flash).to eq("A error prohibited this Commercial from being saved: Commercial can't be blank.")
      expect(conference.commercials.count).to eq(expected_count - 1)

      # Create valid commercial
      select('SlideShare', from: 'commercial_commercial_type')
      fill_in 'commercial_commercial_id', with: '12345'

      click_button 'Create Commercial'
      expect(flash).to eq('Commercial was successfully created.')
      expect(conference.commercials.count).to eq(expected_count)
      expect(page.has_content?('SlideShare')).to be true

      click_link 'Edit'

      # Update without an commercial id
      select('YouTube', from: 'commercial_commercial_type')
      fill_in 'commercial_commercial_id', with: ''

      click_button 'Update Commercial'
      expect(flash).to eq("A error prohibited this Commercial from being saved: Commercial can't be blank.")
      expect(conference.commercials.count).to eq(expected_count)

      # Update valid commercial
      select('YouTube', from: 'commercial_commercial_type')
      fill_in 'commercial_commercial_id', with: '678910'

      click_button 'Update Commercial'
      expect(flash).to eq('Commercial was successfully updated.')
      expect(conference.commercials.count).to eq(expected_count)

      # Delete commercial
      click_link 'Delete'

      expect(flash).to eq('Commercial was successfully destroyed.')
      expect(conference.commercials.count).to eq(expected_count - 1)
    end
  end

  describe 'admin' do
    it_behaves_like 'adds and updates a commercial', :admin
  end

  describe 'organizer' do
    it_behaves_like 'adds and updates a commercial', :organizer
  end
end
