class Commercial < ActiveRecord::Base
  belongs_to :commercialable, polymorphic: true

  attr_accessible :commercial_id, :commercial_type

  validates :commercial_id, presence: true
  validates :commercial_type, presence: true

  validates :commercial_type, inclusion: { in: CONFIG['commercial_types'].values }
end
