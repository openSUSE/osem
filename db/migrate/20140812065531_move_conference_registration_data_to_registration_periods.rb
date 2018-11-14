# frozen_string_literal: true

class MoveConferenceRegistrationDataToRegistrationPeriods < ActiveRecord::Migration
  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'
  end

  class TempRegistrationPeriod < ActiveRecord::Base
    self.table_name = 'registration_periods'
  end

  def up
    # Move all the settings to the new object
    TempConference.all.each do |conference|
      unless TempRegistrationPeriod.exists?(conference_id: conference.id)
        TempRegistrationPeriod.create(conference_id: conference.id,
                                      start_date:    conference.registration_start_date,
                                      end_date:      conference.registration_end_date,
                                      description:   conference.registration_description)
      end
    end

    # Remove Columns
    remove_column :conferences, :registration_start_date
    remove_column :conferences, :registration_end_date
    remove_column :conferences, :registration_description
  end

  def down
    add_column :conferences, :registration_start_date, :date
    add_column :conferences, :registration_end_date, :date
    add_column :conferences, :registration_description, :text
  end
end
