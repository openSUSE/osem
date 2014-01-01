class Vchoice < ActiveRecord::Base
  belongs_to :vday
  belongs_to :vposition

  has_and_belongs_to_many :registrations
end
