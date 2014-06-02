class Venue < ActiveRecord::Base
  attr_accessible :name, :description, :website, :address, :photo
  has_many :conferences
  before_create :generate_guid
  has_attached_file :photo,
                    styles: { thumb: '100x100>', large: '300x300>' }

  validates_attachment_content_type :photo,
                                    content_type: [/jpg/, /jpeg/, /png/, /gif/],
                                    size: { in: 0..500.kilobytes }
  private

  def generate_guid
    begin
      guid = SecureRandom.urlsafe_base64
    end while Venue.where(:guid => guid).exists?
    self.guid = guid
  end

end
