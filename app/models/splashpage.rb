class Splashpage < ActiveRecord::Base
  belongs_to :conference

  attr_accessible :banner_description, :ticket_description, :sponsor_description, :lodging_description,
                  :registration_description, :include_registrations, :include_sponsors,
                  :include_tracks, :include_tickets, :include_program, :public, :banner_photo, :include_banner,
                  :include_social_media, :include_lodgings, :include_venue, :lodging_description

  has_attached_file :banner_photo,
                    styles: { thumb: '100x100>', large: '1300x700>' }

  validates_attachment_content_type :banner_photo,
                                    content_type: [/jpg/, /jpeg/, /png/, /gif/],
                                    size: { in: 0..500.kilobytes }
end
