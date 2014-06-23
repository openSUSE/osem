class SupporterRegistration < ActiveRecord::Base
  belongs_to :supporter_level
  belongs_to :registration
  before_save :set_attributes_from_user

  attr_accessible :registration, :supporter_level_id, :name, :email, :supporter_level, :code, :code_is_valid, :conference_id

  def set_attributes_from_user
    self.name ||= registration.try(:user).try(:name)
    self.email ||= registration.try(:user).try(:email)
    true
  end
end
