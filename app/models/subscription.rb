class Subscription < ActiveRecord::Base
  validates :user_id, uniqueness: { scope: [:conference_id] }
  belongs_to :conference
  belongs_to :user

  has_paper_trail on: %i(create destroy), ignore: [:updated_at], meta: { conference_id: :conference_id }

  validates :user_id, uniqueness: { scope: :conference_id, message: 'already subscribed!' }
end
