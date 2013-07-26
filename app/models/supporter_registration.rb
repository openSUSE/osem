class SupporterRegistration < ActiveRecord::Base
  belongs_to :supporter_level
  belongs_to :registration
  before_save :set_attributes_from_person

  attr_accessible :registration, :supporter_level_id, :name, :email, :supporter_level, :code, :code_is_valid, :conference_id

  def set_attributes_from_person
    self.name ||= registration.try(:person).try(:public_name)
    self.email ||= registration.try(:person).try(:email)
    true
  end
end
