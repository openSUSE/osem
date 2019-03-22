# frozen_string_literal: true

require 'spec_helper'

feature Lodging do
  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }

  scenario 'Add a lodging', feature: true, js: true do
    path = "#{Rails.root}/app/assets/images/rails.png"

    sign_in organizer
    visit admin_conference_lodgings_path(
              conference_id: conference.short_title)
    # Add lodging
    click_link 'Add Lodging'

    fill_in 'lodging_name', with: 'New lodging'
    fill_in 'lodging_website_link', with: 'http://www.google.com'
    attach_file 'Picture', path

    click_button 'Create Lodging'
    page.find('#flash')
    # Validations
    expect(flash).to eq('Lodging successfully created.')
    expect(page.has_content?('New lodging')).to be true
    expect(Lodging.count).to eq(1)
  end

  scenario 'Update a lodging', feature: true, js: true do
    path = "#{Rails.root}/app/assets/images/rails.png"

    lodging = create(:lodging, conference: conference)

    sign_in organizer
    visit admin_conference_lodgings_path(
              conference_id: conference.short_title)

    expect(page.has_content?(CGI.escapeHTML(lodging.name))).to be true

    # Add lodging
    click_link 'Edit'

    fill_in 'lodging_name', with: 'New lodging'
    fill_in 'lodging_website_link', with: 'http://www.google.com'
    attach_file 'Picture', path

    click_button 'Update Lodging'
    page.find('#flash')
    # Validations
    expect(flash).to eq('Lodging successfully updated.')
    expect(page.has_content?('New lodging')).to be true
    lodging.reload
    expect(lodging.name).to eq('New lodging')
    expect(lodging.description).to eq(CGI.escapeHTML(lodging.description))
    expect(lodging.website_link).to eq('http://www.google.com')
    expect(Lodging.count).to eq(1)
  end

  scenario 'Delete a lodging', feature: true, js: true do
    lodging = create(:lodging, conference: conference)

    sign_in organizer
    visit admin_conference_lodgings_path(
              conference_id: conference.short_title)

    expect(page.has_content?(lodging.name)).to be true

    page.accept_alert do
      click_link 'Delete'
    end
    page.find('#flash')
    # Validations
    expect(flash).to eq('Lodging successfully deleted.')
    expect(page.has_content?(CGI.escapeHTML(lodging.name))).to be false
    expect(Lodging.count).to eq(0)
  end
end
