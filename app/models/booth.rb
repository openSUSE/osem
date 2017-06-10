class Booth < ActiveRecord::Base
  belongs_to :conference
  has_many :booth_requests
  has_many :users, through: :booth_requests

  validates :title,
            uniqueness: { case_sensitive: false },
            presence: true

  validates :description,
            :reasoning,
            :state,
            :logo_link,
            :conference_id,
            presence: true
end
