# frozen_string_literal: true

class MoveEventMediaToCommercial < ActiveRecord::Migration
  class TempEvent < ApplicationRecord
    self.table_name = 'events'
  end

  class TempCommercial < ApplicationRecord
    self.table_name = 'commercials'
  end

  def change
    # Move all the settings to the new object
    TempEvent.all.each do |event|
      next if TempCommercial.exists?(commercialable_id: event.id, commercialable_id: 'Conference')
      next if event.media_id.blank? || event.media_type.blank?
      TempCommercial.create(commercial_id: event.media_id,
                            commercial_type: event.media_type,
                            commercialable_id: event.id,
                            commercialable_type: 'Event')
    end

    # Then remove all the columns
    remove_column :events, :media_id
    remove_column :events, :media_type
  end
end
