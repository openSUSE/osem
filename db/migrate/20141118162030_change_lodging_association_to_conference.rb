# frozen_string_literal: true

class ChangeLodgingAssociationToConference < ActiveRecord::Migration
  class TempConference < ApplicationRecord
    self.table_name = 'conferences'
  end

  class TempVenue < ApplicationRecord
    self.table_name = 'venues'
  end

  class TempLodging < ApplicationRecord
    self.table_name = 'lodgings'
  end

  def change
    add_column :lodgings, :conference_id, :integer
    TempLodging.reset_column_information

    # Change association from venue and conference
    TempConference.all.each do |conference|
      next unless TempVenue.exists?(conference_id: conference.id)
      venue = TempVenue.find_by(conference_id: conference.id)
      lodgings = TempLodging.where(venue_id: venue.id)
      lodgings.each do |lodging|
        lodging.update(conference_id: conference.id)
      end
    end

    remove_column :lodgings, :venue_id, :integer
  end
end
