class BoothRequest < ActiveRecord::Base
  belongs_to :booth
  belongs_to :user

  validates :booth,
            :user,
            :role,
            presence: true

  ROLES = [%w[Submitter submitter], %w[Responsible responsible], %w[Secondary secondary]]

end
