class BoothRequest < ActiveRecord::Base
  belongs_to :booth
  belongs_to :user
end
