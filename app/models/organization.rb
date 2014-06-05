class Organization < ActiveRecord::Base
  attr_accessible :name, :logo, :description, :phone_number, :email, :website_url
  has_attached_file :logo,
                    styles: { thumb: '100x100>', large: '300x300>' }

  validates_attachment_content_type :logo,
                                    content_type: [/jpg/, /jpeg/, /png/, /gif/],
                                    size: { in: 0..500.kilobytes }
  validates_presence_of :name, :website_url
  validates_uniqueness_of :email
end
