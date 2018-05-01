# frozen_string_literal: true

namespace :data do
  desc 'Update resources with nil quantity/used fields'
  task normalize_resources: :environment do
    Resource.where('used is ? or quantity is ?', nil, nil).each do |resource|
      resource.used = 0 if resource.used.blank?
      resource.quantity = resource.used if resource.quantity.blank?
      puts "Failed to update resource #{resource.name} (ID #{resource.id})" unless resource.save
    end
  end
end
