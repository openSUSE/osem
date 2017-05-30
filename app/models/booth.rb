class Booth < ActiveRecord::Base
  belongs_to :conference
  has_many :booth_requests
  has_many :users, through: :booth_requests

  validate :title, presence: true
end
