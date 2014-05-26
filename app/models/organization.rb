class Organization < ActiveRecord::Base
  attr_accessible :title, :photo, :email_id, :description, :website_url
  has_many :sponsorship_registrations, dependent: :destroy
  has_attached_file :photo,
                    styles: { thumb: '100x100>', large: '300x300>' }

  validates_attachment_content_type :photo,
                                    content_type: [/jpg/, /jpeg/, /png/, /gif/],
                                    size: { in: 0..500.kilobytes }
  validates_presence_of :title,
                        :email_id,
                        :website_url
  validates_uniqueness_of :email_id
end
