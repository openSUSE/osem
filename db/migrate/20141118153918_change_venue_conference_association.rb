# frozen_string_literal: true

class ChangeVenueConferenceAssociation < ActiveRecord::Migration
  class TempConference < ApplicationRecord
    self.table_name = 'conferences'
  end

  class TempVenue < ApplicationRecord
    self.table_name = 'venues'
  end

  def change
    add_column :venues, :conference_id, :integer
    TempVenue.reset_column_information

    # Change association from venue and conference
    TempConference.all.each do |conference|
      if TempVenue.exists?(id: conference.venue_id)
        venue = TempVenue.find_by(id: conference.venue_id)
        venue.update(conference_id: conference.id)
      end
    end

    remove_column :conferences, :venue_id, :integer
  end
end
