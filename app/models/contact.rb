class Contact < ActiveRecord::Base
  attr_accessible :conference_id, :social_tag, :email, :facebook, :googleplus, :twitter,
                  :instagram, :public, :sponsor_email

  belongs_to :conference

  validates :conference, presence: true
  # Conferences only have one contact
  validates :conference_id, uniqueness: {message: 'has already contact details'}

  validates :facebook, :twitter, :googleplus, :instagram,
            format: URI::regexp(%w(http https)), allow_blank: true

  def has_social_media?
    return true if !facebook.blank? || !twitter.blank? || !googleplus.blank? || !instagram.blank?
    false
  end
end
