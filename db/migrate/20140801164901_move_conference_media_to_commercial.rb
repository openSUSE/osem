# frozen_string_literal: true

class MoveConferenceMediaToCommercial < ActiveRecord::Migration
  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'
  end

  class TempCommercial < ActiveRecord::Base
    self.table_name = 'commercials'
  end

  def change
    # Move all the settings to the new object
    TempConference.all.each do |conference|
      unless TempCommercial.exists?(commercialable_id: conference.id, commercialable_id: 'Conference')
        unless conference.media_id.blank? || conference.media_type.blank?
          TempCommercial.create(commercial_id:       conference.media_id,
                                commercial_type:     conference.media_type,
                                commercialable_id:   conference.id,
                                commercialable_type: 'Conference')
        end
      end
    end

    # Then remove all the columns
    remove_column :conferences, :media_id
    remove_column :conferences, :media_type
  end
end
