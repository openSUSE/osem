class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  has_and_belongs_to_many :roles
  has_one :person, :inverse_of => :user

  attr_accessible :email, :password, :password_confirmation, :remember_me, :role_id, :role_ids, :person_attributes
  accepts_nested_attributes_for :person
  accepts_nested_attributes_for :roles

  before_save :setup_role
  before_create :create_person

  delegate :last_name, :first_name, :public_name, :email, to: :person

  def role?(role)
    Rails.logger.debug("Checking role in user")
    return !!self.roles.find_by_name(role.to_s.camelize)
  end

  def get_roles
    return self.roles
  end

  def setup_role
    if self.id == 1
      self.role_ids = [3]
    end
    
    if self.role_ids.empty?
      self.role_ids = [1]
    end
  end

  def popup_details
    details = "<b>Sign-in Count</b><br>"
    details += "#{self.sign_in_count}<br>"
    details += "<b>Current Sign-in</b><br>"
    details += "#{self.current_sign_in_at}<br>"
    details += "<b>Last Sign-in</b><br>"
    details += "#{self.last_sign_in_at}<br>"
    details += "<b>Current Sign-in IP</b><br>"
    details += "#{self.current_sign_in_ip}<br>"
    details += "<b>Last Sign-in IP</b><br>"
    details += "#{self.last_sign_in_ip}<br>"
    details += "<b>Created at</b><br>"
    details += "#{self.created_at}<br>"
  end

  private
    def create_person
      # TODO Search people for existing email address, add to their account
      build_person(:email => self.email) if person.nil?
      true
    end
end
