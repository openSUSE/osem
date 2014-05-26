class SponsorshipRegistration < ActiveRecord::Base
  attr_accessible :name, :email_id, :contact_no, :amount_donated, :method_of_donation,
                  :sponsorship_level_id, :conference_id, :organization_id
  belongs_to :organization
  belongs_to :sponsorship_level
  belongs_to :conference
  validates_presence_of :name, :email_id, :contact_no, :amount_donated,
                        :method_of_donation, :sponsorship_level,
                        :conference, :organization
  validates_uniqueness_of :email_id
end
