class Invite < ApplicationRecord
  attr_accessor :emails
  belongs_to :conference

  validates :end_date, presence: true
  validates :invite_for, presence: true
  validates :user_id, presence: true, uniqueness: { scope: [:invite_for, :conference_id] }
end
