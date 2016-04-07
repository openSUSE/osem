class Sponsor < ActiveRecord::Base
  belongs_to :sponsorship_level
  belongs_to :conference
  has_attached_file :logo,
                    styles: { thumb: '100x100>', large: '300x300>' }

  validates_attachment_content_type :logo,
                                    content_type: [/jpg/, /jpeg/, /png/, /gif/],
                                    size: { in: 0..500.kilobytes },
                                    presence: true

  validates_presence_of :name, :website_url, :sponsorship_level
end
