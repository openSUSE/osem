class Vposition < ActiveRecord::Base
  belongs_to :conference

  has_many :vchoices
  has_many :vdays, through: :vchoices

  validates_presence_of :title, :vdays
end
