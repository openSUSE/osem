class Vote < ActiveRecord::Base
  attr_accessible :rating
  
  belongs_to :person
  belongs_to :event
  
  delegate :first_name, :to => :person
  delegate :last_name, :to => :person
  delegate :public_name, :to => :person
end