class Contact < ActiveRecord::Base
  attr_accessible :conference, :social_tag, :email, :facebook, :googleplus, :twitter, :instagram, :public
  belongs_to :conference

  validates :conference, presence: true
  # Conferences only have one contact
  validates :conference_id, :uniqueness => {:message => "has already contact details"}
end
