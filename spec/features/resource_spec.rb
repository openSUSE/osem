# frozen_string_literal: true

require 'spec_helper'

feature Resource do
  let!(:conference) { create(:conference) }
  let!(:admin) { create(:admin) }
  let!(:resource) { create(:resource, conference: conference) }

  context 'as an admin' do
    before(:each) do
      sign_in admin
    end

    scenario 'create a new resource' do
      visit admin_conference_resources_path(conference.short_title)
      click_link 'Add Resource'

      fill_in 'resource_name', with: 'shirts'
      fill_in 'resource_description', with: 'what you love to wear!'
      fill_in 'resource_quantity', with: 10

      click_button 'Create Resource'

      expect(Resource.count).to eq(2)
      page.find('#flash')
      expect(flash).to eq('Resource successfully created.')
    end

    scenario 'edit an existing resource' do
      visit admin_conference_resources_path(conference.short_title)
      click_link('Edit')
      fill_in 'resource_name', with: 'changed_name'
      click_button 'Update Resource'
      resource.reload
      page.find('#flash')
      expect(flash).to eq('Resource successfully updated.')
      expect(resource.name).to eq('changed_name')
    end

    scenario 'destroy a resource' do
      visit admin_conference_resources_path(conference.short_title)
      click_link('Delete', href: admin_conference_resource_path(conference.short_title, resource.id))

      page.find('#flash')
      expect(flash).to eq('Resource successfully destroyed.')
    end
  end
end
