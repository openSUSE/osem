class Splashpage < ActiveRecord::Base
  belongs_to :conference
  attr_accessible :public,
                  :include_tracks, :include_program, :include_cfp,
                  :include_venue, :include_registrations,
                  :include_tickets, :include_lodgings,
                  :include_sponsors, :include_social_media
end
