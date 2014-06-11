class Lodging < ActiveRecord::Base
  attr_accessible :name, :description, :photo, :website_link
  belongs_to :venue
  has_attached_file :photo,
                    styles: { thumb: '100x100>', large: '300x300>' }

  validates_attachment_content_type :photo,
                                    content_type: [/jpg/, /jpeg/, /png/, /gif/],
                                    size: { in: 0..500.kilobytes }
end
