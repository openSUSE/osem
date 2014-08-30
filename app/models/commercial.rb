class Commercial < ActiveRecord::Base
  belongs_to :commercialable, polymorphic: true

  attr_accessible :commercial_id, :commercial_type

  validates :commercial_id, :commercial_type, presence: true

  validates :commercial_type, inclusion: { in: :get_types_enum }, allow_blank: true

  def get_types_enum
    CONFIG['commercial_types'].nil? ? nil : CONFIG['commercial_types'].values
  end
end
