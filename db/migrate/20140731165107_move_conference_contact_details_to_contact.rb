# frozen_string_literal: true

class MoveConferenceContactDetailsToContact < ActiveRecord::Migration
  class TempConference < ActiveRecord::Base
    self.table_name = 'conferences'
  end

  class TempContact < ActiveRecord::Base
    self.table_name = 'contacts'
  end

  def change
    # Move all the settings to the new object
    TempConference.all.each do |conference|
      unless TempContact.exists?(conference_id: conference.id)
        TempContact.create(social_tag:    conference.social_tag,
                           email:         conference.contact_email,
                           facebook:      conference.facebook_url,
                           googleplus:    conference.google_url,
                           twitter:       conference.twitter_url,
                           instagram:     conference.instagram_url,
                           public:        conference.include_social_media_in_splash,
                           conference_id: conference.id)
      end
    end
    # Then remove all the columns
    remove_column :conferences, :social_tag
    remove_column :conferences, :contact_email
    remove_column :conferences, :facebook_url
    remove_column :conferences, :google_url
    remove_column :conferences, :twitter_url
    remove_column :conferences, :instagram_url
    remove_column :conferences, :include_social_media_in_splash
  end
end
