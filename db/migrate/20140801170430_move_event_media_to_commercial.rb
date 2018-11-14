# frozen_string_literal: true

class MoveEventMediaToCommercial < ActiveRecord::Migration
  class TempEvent < ActiveRecord::Base
    self.table_name = 'events'
  end

  class TempCommercial < ActiveRecord::Base
    self.table_name = 'commercials'
  end

  def change
    # Move all the settings to the new object
    TempEvent.all.each do |event|
      unless TempCommercial.exists?(commercialable_id: event.id, commercialable_id: 'Conference')
        unless event.media_id.blank? || event.media_type.blank?
          TempCommercial.create(commercial_id:       event.media_id,
                                commercial_type:     event.media_type,
                                commercialable_id:   event.id,
                                commercialable_type: 'Event')
        end
      end
    end

    # Then remove all the columns
    remove_column :events, :media_id
    remove_column :events, :media_type
  end
end
