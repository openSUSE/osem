class IChainRecordNotFound < StandardError
end

class UserDisabled < StandardError
end

class User < ApplicationRecord
  rolify
  has_many :physical_tickets, through: :ticket_purchases do
    def by_conference(conference)
      where('ticket_purchases.conference_id = ?', conference)
    end
  end
  has_many :users_roles
  has_many :roles, through: :users_roles, dependent: :destroy

  has_paper_trail on: [:create, :update], ignore: [:sign_in_count, :remember_created_at, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :unconfirmed_email,
                                                   :avatar_content_type, :avatar_file_size, :avatar_updated_at, :updated_at, :confirmation_sent_at, :confirmation_token, :reset_password_token]

  include Gravtastic
  gravtastic size: 32

  before_create :setup_role

  # add scope
  scope :comment_notifiable, ->(conference) {joins(:roles).where('roles.name IN (?)', [:organizer, :cfp]).where('roles.resource_type = ? AND roles.resource_id = ?', 'Conference', conference.id)}

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise_modules = []

  devise_modules += if ENV['OSEM_ICHAIN_ENABLED'] == 'true'
                      [:ichain_authenticatable, :ichain_registerable, :omniauthable, omniauth_providers: []]
                    else
                      [:database_authenticatable, :registerable,
                       :recoverable, :rememberable, :trackable, :validatable, :confirmable,
                       :omniauthable, omniauth_providers: [:suse, :google, :facebook, :github]]
                    end

  devise(*devise_modules)

  has_many :openids

  attr_accessor :login

  has_many :event_users, dependent: :destroy
  has_many :events, -> { distinct }, through: :event_users
  has_many :presented_events, -> { joins(:event_users).where(event_users: {event_role: 'speaker'}).distinct }, through: :event_users, source: :event
  has_many :registrations, dependent: :destroy do
    def for_conference conference
      where(conference: conference).first
    end
  end
  has_many :events_registrations, through: :registrations
  has_many :ticket_purchases, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :tickets, through: :ticket_purchases, source: :ticket do
    def for_registration conference
      where(conference: conference, registration_ticket: true).first
    end
  end
  has_many :votes, dependent: :destroy
  has_many :voted_events, through: :votes, source: :events
  has_many :subscriptions, dependent: :destroy
  has_many :tracks, foreign_key: 'submitter_id'
  has_many :booth_requests
  has_many :booth_requests, dependent: :destroy
  has_many :booths, through: :booth_requests
  accepts_nested_attributes_for :roles

  scope :admin, -> { where(is_admin: true) }
  scope :active, -> { where(is_disabled: false) }

  validates :email, presence: true

  validates :username,
            uniqueness: {
                case_sensitive: false
            },
            presence: true

  validate :biography_limit

  ##
  # Checkes if the user attended the event
  # This is used for events that require registration
  # The user must have registered to attend the event
  # Gets an event
  # === Returns
  # * +true+ if the user attended the event
  # * +false+ if the user did not attend the event
  def attended_event? event
    event_registration = event.events_registrations.find_by(registration: registrations)

    return false unless event_registration.present?
    event_registration.attended
  end

  def mark_attendance_for_conference conference
    registration = registrations.for_conference(conference)
    registration.attended = true
    registration.save
  end

  def name
    self[:name].blank? ? username : self[:name]
  end

  ##
  # Checks if a user has registered to an event
  # ====Returns
  # * +true+ or +false+
  def registered_to_event? event
    event.registrations.include? registrations.find_by(conference: event.program.conference)
  end

  def subscribed? conference
    subscriptions.find_by(conference_id: conference.id).present?
  end

  def supports? conference
    ticket_purchases.find_by(conference_id: conference.id).present?
  end

  def self.for_ichain_username(username, attributes)
    user = find_by(username: username)

    raise UserDisabled if user && user.is_disabled

    if user
      user.update_attributes(email: attributes[:email],
                             last_sign_in_at: user.current_sign_in_at,
                             current_sign_in_at: Time.current)
    else
      begin
        user = create!(username: username, email: attributes[:email])
      rescue ActiveRecord::RecordNotUnique
        raise IChainRecordNotFound
      end
    end
    user
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    if login
      where(conditions).where(['lower(username) = :value OR lower(email) = :value', { value: login.downcase }]).first
    else
      where(conditions).first
    end
  end

  # Searches for user based on email. Returns found user or new user.
  # ====Returns
  # * +User::ActiveRecord_Relation+ -> user
  def self.find_for_auth(auth, current_user = nil)
    user = current_user

    if user.nil? # No current user available, user is not already logged in
      user = User.where(email: auth.info.email).first_or_initialize
    end

    if user.new_record?
      user.email = auth.info.email
      user.name = auth.info.name
      user.username = auth.info.username
      user.password = Devise.friendly_token[0, 20]
      user.skip_confirmation!
    end

    user
  end

  # Gets the roles of the user, groups them by role.name and returns the resource(s) of each role
  # ====Returns
  # * +Hash+ * ->  e.g. 'organizer' =>  [conf1, conf2]
  def get_roles
    result = {}
    roles.each do |role|
      resource = if role.resource_type == 'Conference'
                   Conference.find(role.resource_id).short_title
                 elsif role.resource_type == 'Track'
                   Track.find(role.resource_id).name
                 end
      if result[role.name].nil?
        result[role.name] = [resource]
      else
        result[role.name] << resource
      end
    end
    result
  end

  def registered
    registrations = self.registrations
    if registrations.count == 0
      'None'
    else
      registrations.map { |r| r.conference.title }.join ', '
    end
  end

  def attended
    registrations_attended = registrations.where(attended: true)
    if registrations_attended.count == 0
      'None'
    else
      registrations_attended.map { |r| r.conference.title }.join ', '
    end
  end

  def confirmed?
    !confirmed_at.nil?
  end

  def proposals(conference)
    events.where('program_id = ? AND (event_users.event_role = ? OR event_users.event_role = ?)', conference.program.id, 'submitter', 'speaker')
  end

  def proposal_count(conference)
    proposals(conference).count
  end

  private

  def setup_role
    if User.count == 1 && User.first.email == 'deleted@localhost.osem'
      self.is_admin = true
    end
  end

  ##
  # Check if biography has an allowed number of words. Used as validation.
  #
  def biography_limit
    if biography.present?
      errors.add(:biography, 'is limited to 150 words.') if biography.split.length > 150
    end
  end
end
