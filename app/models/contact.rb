class Contact < ActiveRecord::Base
  belongs_to :conference

  validates :conference, presence: true
  # Conferences only have one contact
  validates :facebook, :twitter, :googleplus, :instagram,
            format: URI::regexp(%w(http https)), allow_blank: true

  def has_social_media?
    return true if facebook.present? || twitter.present? || googleplus.present? || instagram.present? || email.present?
    false
  end
end
