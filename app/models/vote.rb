class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  delegate :name, to: :user
end
