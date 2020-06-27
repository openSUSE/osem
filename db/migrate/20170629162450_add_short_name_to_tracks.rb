# frozen_string_literal: true

class AddShortNameToTracks < ActiveRecord::Migration[4.2]
  class TmpProgram < ActiveRecord::Base
    self.table_name = 'programs'
  end

  class TmpTrack < ActiveRecord::Base
    self.table_name = 'tracks'
  end

  def change
    add_column :tracks, :short_name, :string

    TmpTrack.reset_column_information

    TmpProgram.find_each do |program|
      # Keeps count of how many times we've encountered a short_name
      track_name_counter = {}

      TmpTrack.where(program_id: program.id).find_each do |track|
        # Replace spaces with undercores and remove the non alphanumeric characters that aren't underscores or dashes
        short_name = track.name.tr(' ', '_').tr('^a-zA-Z0-9_-', '')

        # If we've seen that short_name before then add the counter in the end to avoid collisions
        if track_name_counter[short_name]
          track_name_counter[short_name] += 1
          short_name += "_#{track_name_counter[short_name]}"
        else
          # Initialize the counter
          track_name_counter[short_name] = 0 unless track_name_counter[short_name]
        end

        track.short_name = short_name
        track.save!
      end
    end

    change_column_null :tracks, :short_name, false
  end
end
