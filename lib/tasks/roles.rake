# frozen_string_literal: true

namespace :roles do
  desc 'Adds back deleted roles to all conferences'
  task add: :environment do

    Organization.all.each do |org|
      Role.where(name: 'organization_admin', resource: org).first_or_create(description: 'For the administrators of an organization and its conferences')
    end

    Conference.all.each do |c|
      Role.where(name: 'organizer', resource: c).first_or_create(description: 'For the organizers of the conference (who shall have full access)')
      Role.where(name: 'cfp', resource: c).first_or_create(description: 'For the members of the CfP team')
      Role.where(name: 'info_desk', resource: c).first_or_create(description: 'For the members of the Info Desk team')
      Role.where(name: 'volunteers_coordinator', resource: c).first_or_create(description: 'For the people in charge of volunteers')
    end

    puts 'All done!'
  end
end

