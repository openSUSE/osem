class Sponsor < ActiveRecord::Base
  belongs_to :sponsorship_level
  belongs_to :conference
  has_attached_file :logo,
                    styles: { thumb: '100x100>',
                              first: '320x180>',
                              second: '320x150>',
                              others: '320x120>' },
                    # places logo on a white background to maintain size
                    convert_options: {
                      first: '-background white -gravity center -extent 320x180',
                      second: '-background white -gravity center -extent 320x150',
                      others: '-background white -gravity center -extent 320x120'
                    }

  validates_attachment_content_type :logo,
                                    content_type: [/jpg/, /jpeg/, /png/, /gif/],
                                    size: { in: 0..500.kilobytes }

  validates_presence_of :name, :website_url, :sponsorship_level, :logo
end
