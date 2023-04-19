# frozen_string_literal: true

require 'spec_helper'

def have_rating(rating, max)
  have_selector('.rating.bright', count: rating)
    .and have_selector('.rating:not(.bright)', count: max - rating)
end

def cast_vote(rating, before:, after:)
  # Index shows existing rating but not user’s vote
  visit admin_conference_program_events_path(conference.short_title)
  within("#event-#{event.id}") do
    expect(page).to have_rating(before, 5)
    expect(page).to have_text('Not rated')
  end

  # Event page shows existing rating but not user’s vote
  click_on event.title
  within('tr', text: 'Rating') { expect(page).to have_rating(before, 5) }
  within('tr', text: 'Your vote') { expect(page).to have_rating(0, 5) }

  # Voting dynamically updates the page
  within('tr', text: 'Your vote') { page.find(".rating:nth-of-type(#{rating})").click }
  within('tr', text: 'Rating') { expect(page).to have_rating(after, 5) }
  within('tr', text: 'Your vote') { expect(page).to have_rating(rating, 5) }

  # Index shows updated rating and vote
  visit admin_conference_program_events_path(conference.short_title)
  within("#event-#{event.id}") do
    expect(page).to have_rating(after, 5)
    expect(page).to have_text("You voted: #{rating}/5")
  end

  # Re-rendered event page shows updated rating and vote
  click_on event.title
  within('tr', text: 'Rating') { expect(page).to have_rating(after, 5) }
  within('tr', text: 'Your vote') { expect(page).to have_rating(rating, 5) }
end

feature 'Voting' do
  let(:conference) { create(:conference) }
  let!(:event) { create(:event, program: conference.program) }
  let(:voter1) { create(:cfp_user, resource: conference) }
  let(:voter2) { create(:cfp_user, resource: conference) }

  before :each do
    conference.program.update_attribute :rating, 5
  end

  scenario 'multiple users casting votes', feature: true, js: true do
    sign_in voter1
    cast_vote 3, before: 0, after: 3
    sign_out

    sign_in voter2
    cast_vote 5, before: 3, after: 4
  end
end
