class Subscription < ActiveRecord::Base
  validates_uniqueness_of :user_id, scope: [:conference_id]
  belongs_to :conference
  belongs_to :user

  has_paper_trail on: [:create, :destroy], ignore: [:updated_at], meta: { conference_id: :conference_id }

  validates_uniqueness_of :user_id, scope: :conference_id, message: 'already subscribed!'
end
