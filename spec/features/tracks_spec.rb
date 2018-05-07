# frozen_string_literal: true

require 'spec_helper'

feature Track do
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }
  let(:user) { create(:user) }

  shared_examples 'admin tracks' do
    scenario 'adds a track', feature: true, js: true do

      sign_in organizer

      expected = expect do
        visit admin_conference_program_tracks_path(conference_id: conference.short_title)
        click_link 'New Track'

        fill_in 'track_name', with: 'Distribution'
        fill_in 'track_short_name', with: 'Distribution'
        page.find('#track_color').set('#B94D4D')
        fill_in 'track_description', with: 'Events about our Linux distribution'
        click_button 'Create Track'
      end

      expected.to change { Track.count }.by 1
      expect(flash).to eq('Track successfully created.')
      within('table#tracks') do
        expect(page.has_content?('Distribution')).to be true
        expect(page.has_content?('Events about our Linux')).to be true
      end
    end

    scenario 'deletes a track', feature: true, js: true do
      track = create(:track, program_id: conference.program.id)
      sign_in organizer

      expected = expect do
        visit admin_conference_program_tracks_path(conference_id: conference.short_title)
        within('#tracks', visible: true) do
          page.accept_confirm do
            find_link('Delete').click
          end
        end
      end

      expected.to change { Track.count }.by(-1)
      expect(flash).to eq('Track successfully deleted.')
      expect(page.has_css?('table#tracks')).to be false
      expect(page.has_content?(track.name)).to be false
      expect(page.has_content?(track.description)).to be false
    end

    scenario 'updates a track', feature: true, js: true do
      create(:track, program_id: conference.program.id)
      sign_in organizer

      expected = expect do
        visit admin_conference_program_tracks_path(conference_id: conference.short_title)
        within('#tracks', visible: true) do
          find_link('Edit').trigger('click')
        end

        fill_in 'track_name', with: 'Distribution'
        fill_in 'track_short_name', with: 'Distribution'
        page.find('#track_color').set('#B94D4D')
        fill_in 'track_description', with: 'Events about our Linux distribution'
        click_button 'Update Track'
      end

      expected.to_not(change { Track.count })
      expect(flash).to eq('Track successfully updated.')
      within('table#tracks') do
        expect(page.has_content?('Distribution')).to be true
        expect(page.has_content?('Events about our Linux')).to be true
      end
    end
  end

  shared_examples 'non admin tracks' do
    scenario 'adds a track', feature: true, js: true do

      sign_in user

      expected = expect do
        visit conference_program_tracks_path(conference_id: conference.short_title)
        click_link 'New Track request'

        fill_in 'track_name', with: 'Distribution'
        fill_in 'track_short_name', with: 'Distribution'
        page.find('#track_color').set('#B94D4D')
        fill_in 'track_description', with: 'Events about our Linux distribution'
        fill_in 'track_relevance', with: 'Maintainer of super awesome distribution'
        click_button 'Create Track'
      end

      expected.to change { Track.count }.by 1
      expect(flash).to eq('Track request successfully created.')
      within('table#tracks') do
        expect(page.has_content?('Distribution')).to eq true
        expect(page.has_content?('Events about our Linux dist...')).to eq true
      end
    end

    scenario 'withdraws a track', feature: true, js: true do
      track = create(:track, :self_organized, program_id: conference.program.id, submitter: user)
      sign_in user

      expected = expect do
        visit conference_program_tracks_path(conference_id: conference.short_title)

        accept_confirm do
          click_link 'Withdraw'
        end
      end

      expected.to_not(change { Track.count })
      expect(flash).to eq("Track #{track.name} withdrawn.")
      within('table#tracks') do
        expect(page.has_content?(track.name)).to eq true
        expect(page.has_link?('Re-Submit')).to eq true
      end
    end

    scenario 'updates a track', feature: true, js: true do
      create(:track, :self_organized, program_id: conference.program.id, submitter: user)
      sign_in user

      expected = expect do
        visit conference_program_tracks_path(conference_id: conference.short_title)
        click_link 'Edit'

        fill_in 'track_name', with: 'Distribution'
        fill_in 'track_short_name', with: 'Distribution'
        page.find('#track_color').set('#B94D4D')
        fill_in 'track_description', with: 'Events about our Linux distribution'
        click_button 'Update Track'
      end

      expected.to_not(change { Track.count })
      expect(flash).to eq('Track request successfully updated.')
      within('table#tracks') do
        expect(page.has_content?('Distribution')).to eq true
        expect(page.has_content?('Events about our Linux dist...')).to eq true
      end
    end
  end

  describe 'organizer' do
    it_behaves_like 'admin tracks'
  end

  describe 'signed in user' do
    before :each do
      create(:cfp, cfp_type: 'tracks', program: conference.program)
    end

    it_behaves_like 'non admin tracks'
  end
end
