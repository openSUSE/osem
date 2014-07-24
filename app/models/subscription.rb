class Subscription < ActiveRecord::Base
  attr_accessible :user_id, :conference_id
  belongs_to :conference
  belongs_to :user
end
