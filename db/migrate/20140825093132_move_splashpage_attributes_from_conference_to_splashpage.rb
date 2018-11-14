# frozen_string_literal: true

class MoveSplashpageAttributesFromConferenceToSplashpage < ActiveRecord::Migration
  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'
  end

  class TempRegistrationPeriod < ActiveRecord::Base
    self.table_name = 'registration_periods'
  end

  class TempContact < ActiveRecord::Base
    self.table_name = 'contacts'
  end

  class TempVenue < ActiveRecord::Base
    self.table_name = 'venues'
  end

  class TempSplashpage < ActiveRecord::Base
    self.table_name = 'splashpages'
  end

  def change
    # Copy values to splashpage
    TempConference.all.each do |conference|
      unless TempSplashpage.exists?(conference_id: conference.id)
        splash = TempSplashpage.create(conference_id:             conference.id,
                                       public:                    conference.make_conference_public,
                                       include_registrations:     conference.include_registrations_in_splash,
                                       include_tracks:            conference.include_tracks_in_splash,
                                       include_program:           conference.include_program_in_splash,
                                       include_banner:            conference.include_banner_in_splash,
                                       include_tickets:           conference.include_tickets_in_splash,
                                       ticket_description:        conference.ticket_description,
                                       include_sponsors:          conference.include_sponsors_in_splash,
                                       sponsor_description:       conference.sponsor_description,
                                       lodging_description:       conference.lodging_description,
                                       banner_description:        conference.description,
                                       banner_photo_file_name:    conference.banner_photo_file_name,
                                       banner_photo_content_type: conference.banner_photo_content_type,
                                       banner_photo_file_size:    conference.banner_photo_file_size,
                                       banner_photo_updated_at:   conference.banner_photo_updated_at)

        contact = TempContact.find_by(conference_id: conference.id)
        if contact
          splash.include_social_media = contact.public
          splash.save
        end

        registration = TempRegistrationPeriod.find_by(conference_id: conference.id)
        if registration
          splash.registration_description = registration.description
          splash.save
        end

        venue = TempVenue.find_by(id: conference.venue_id)
        if venue
          splash.include_lodgings = venue.include_lodgings_in_splash
          splash.include_venue = venue.include_venue_in_splash
          splash.save
        end
      end
    end

    # Remove columns
    remove_column :contacts, :public
    remove_column :registration_periods, :description
    remove_column :venues, :include_lodgings_in_splash
    remove_column :venues, :include_venue_in_splash
    remove_column :conferences, :ticket_description
    remove_column :conferences, :sponsor_description
    remove_column :conferences, :lodging_description
    remove_column :conferences, :make_conference_public
    remove_column :conferences, :include_registrations_in_splash
    remove_column :conferences, :include_sponsors_in_splash
    remove_column :conferences, :include_tracks_in_splash
    remove_column :conferences, :include_tickets_in_splash
    remove_column :conferences, :include_program_in_splash
    remove_column :conferences, :banner_photo_file_name
    remove_column :conferences, :banner_photo_content_type
    remove_column :conferences, :banner_photo_file_size
    remove_column :conferences, :banner_photo_updated_at
    remove_column :conferences, :include_banner_in_splash
    remove_column :conferences, :description
  end
end
