class RatingCache < ActiveRecord::Base
  belongs_to :cacheable, polymorphic: true
end
