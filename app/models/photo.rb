class Photo < ActiveRecord::Base
  attr_accessible :picture, :description
  belongs_to :conference
  validates_presence_of :picture
  has_attached_file :picture,
                    styles: { thumb: '100x100>', large: '300x300>', banner: '600x300>' }

  validates_attachment_content_type :picture,
                                    content_type: [/jpg/, /jpeg/, /png/, /gif/],
                                    size: { in: 0..500.kilobytes }
end
