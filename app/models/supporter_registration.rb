class SupporterRegistration < ActiveRecord::Base
  belongs_to :supporter_level
  belongs_to :registration

  attr_accessible :registration, :supporter_level_id, :name, :email, :supporter_level, :code, :code_is_valid, :conference_id

end
