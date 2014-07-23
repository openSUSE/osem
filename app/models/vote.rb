class Vote < ActiveRecord::Base
  attr_accessible :rating

  belongs_to :user
  belongs_to :event
  delegate :name, to: :user
end
