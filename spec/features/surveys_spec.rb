# frozen_string_literal: true

require 'spec_helper'

feature Survey do
  let(:conference) { create(:conference) }

  context 'as an organizer' do
    let(:organizer) { create(:organizer, resource: conference) }

    before :each do
      sign_in organizer
    end

    scenario 'create a survey', feature: true, js: true do
      visit admin_conference_path(conference)
      click_link 'Surveys'
      click_link 'New'
      fill_in 'Title', with: 'Example Survey'
      click_button 'Create Survey'
      expect(flash).to eq('Successfully created survey')

      fill_in :survey_question_title, with: 'Example question'
      select 'boolean', from: 'Type of Question:', visible: false # Hidden by bootstrap-select
      click_button 'Create Survey question'
      expect(flash).to eq('Successfully created Survey Question.')
    end
  end

  context 'as an attendee' do
    let!(:attendee) { create(:user) }
    let!(:conference) do
      conf = create(:conference)
      create(:registration_period, conference: conf)
      conf
    end
    let!(:registration) { create(:registration, conference: conference, user: attendee) }
    let!(:survey) do
      survey = create(:survey, surveyable: conference, target: :during_registration)
      create :boolean_mandatory, survey: survey
      survey
    end

    before :each do
      sign_in attendee
    end

    scenario 'respond to a survey during registration', feature: true, js: true do
      visit conference_conference_registration_path(conference)

      click_link survey.title
      choose 'Yes'
      click_button 'Submit'
      expect(flash).to eq('Successfully responded to survey.')

      visit conference_conference_registration_path(conference)
      expect(find(:link, survey.title).sibling('.fa-solid')[:title]).to eq('Thank you for filling out the survey')
    end
  end
end
