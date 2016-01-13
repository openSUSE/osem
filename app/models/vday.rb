class Vday < ActiveRecord::Base
  belongs_to :conference

  has_many :vchoices
  has_many :vpositions, through: :vchoices, dependent: :destroy
end
