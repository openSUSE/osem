# frozen_string_literal: true

class MoveBannerDescriptionToConference < ActiveRecord::Migration
  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'
  end

  class TempSplashpage < ActiveRecord::Base
    self.table_name = 'splashpages'
  end

  def change
    add_column :conferences, :description, :text

    TempConference.reset_column_information
    # Copy value from splash to conferenc
    TempConference.all.each do |conference|
      if TempSplashpage.exists?(conference_id: conference.id)
        splash = TempSplashpage.find_by(conference_id: conference.id)
        conference.update_attributes(description: splash.banner_description)
      end
    end

    remove_column :splashpages, :banner_description, :text
  end
end
