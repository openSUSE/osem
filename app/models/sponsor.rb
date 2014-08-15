class Sponsor < ActiveRecord::Base
  attr_accessible :name, :description, :website_url, :logo, :sponsorship_level_id, :conference_id
  belongs_to :sponsorship_level
  belongs_to :conference
  has_attached_file :logo,
                    styles: { thumb: '100x100>', large: '300x300>' }

  validates_attachment_content_type :logo,
                                    content_type: [/jpg/, /jpeg/, /png/, /gif/],
                                    size: { in: 0..500.kilobytes }
  validates_presence_of :name, :website_url, :sponsorship_level
end
