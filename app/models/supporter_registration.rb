class SupporterRegistration < ActiveRecord::Base
  belongs_to :supporter_level
  belongs_to :registration

  attr_accessible :registration, :supporter_level_id, :code, :code_is_valid
end
