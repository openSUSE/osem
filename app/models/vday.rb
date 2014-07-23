class Vday < ActiveRecord::Base
  attr_accessible :day, :description

  belongs_to :conference

  has_many :vchoices
  has_many :vpositions, through: :vchoices, dependent: :destroy
end
