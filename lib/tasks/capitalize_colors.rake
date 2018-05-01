# frozen_string_literal: true

namespace :data do
  desc 'Catitalize tracks, event types and difficult levels colors'

  task capitalize_colors: :environment do
    capitalize_collection_colors(Track)
    puts "Tracks' colors capitalized"

    capitalize_collection_colors(DifficultyLevel)
    puts "Difficulty levels' colors capitalized"

    capitalize_collection_colors(EventType)
    puts "Event types' colors capitalized"
  end

  def capitalize_collection_colors(model)
    model.all.each do |item|
      item.color = item.color.upcase
      item.save!
    end
  end
end
