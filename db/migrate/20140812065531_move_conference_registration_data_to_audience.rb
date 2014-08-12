class MoveConferenceRegistrationDataToAudience < ActiveRecord::Migration
  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'
  end

  class TempAudience < ActiveRecord::Base
    self.table_name = 'audiences'
    attr_accessible :conference_id, :registration_start_date, :registration_end_date, :registration_description
  end

  def change
    # Move all the settings to the new object
    TempConference.all.each do |conference|
      unless TempAudience.exists?(conference_id: conference.id)
        TempAudience.create(conference_id: conference.id,
                            registration_start_date: conference.registration_start_date,
                            registration_end_date: conference.registration_end_date,
                            registration_description: conference.registration_description)
      end
    end

    # Remove Columns
    remove_column :conferences, :registration_start_date
    remove_column :conferences, :registration_end_date
    remove_column :conferences, :registration_description
  end
end
