class IChainRecordNotFound < StandardError
end

class UserDisabled < StandardError
end

class User < ActiveRecord::Base
  rolify
  include Gravtastic
  gravtastic size: 32

  before_create :setup_role

  # add scope
  scope :comment_notifiable, ->(conference) {joins(:roles).where('roles.name IN (?)', [:organizer, :cfp]).where('roles.resource_type = ? AND roles.resource_id = ?', 'Conference', conference.id)}

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise_modules = []

  if CONFIG['authentication']['ichain']['enabled']
    devise_modules += [ :ichain_authenticatable, :ichain_registerable, :omniauthable, omniauth_providers: [] ]
  else
    devise_modules += [:database_authenticatable, :registerable,
                       :recoverable, :rememberable, :trackable, :validatable, :confirmable,
                       :omniauthable, omniauth_providers: [:suse, :google, :facebook, :github] ]
  end

  devise(*devise_modules)

  has_and_belongs_to_many :roles
  has_many :openids

  attr_accessible :email, :password, :password_confirmation, :remember_me, :role_id, :role_ids,
                  :name, :email_public, :biography, :nickname, :affiliation, :is_admin,
                  :tshirt, :mobile, :volunteer_experience, :languages, :username, :login, :is_disabled

  attr_accessor :login

  has_many :event_users, dependent: :destroy
  has_many :events, -> { uniq }, through: :event_users
  has_many :registrations, dependent: :destroy
  has_many :ticket_purchases, dependent: :destroy
  has_many :tickets, through: :ticket_purchases, source: :ticket
  has_many :votes, dependent: :destroy
  has_many :voted_events, through: :votes, source: :events
  has_many :subscriptions, dependent: :destroy
  accepts_nested_attributes_for :roles

  scope :admin, -> { where(is_admin: true) }

  validates :email, presence: true

  validates :username,
            uniqueness: {
                case_sensitive: false
            },
            presence: true

  def subscribed? conference
    self.subscriptions.find_by(conference_id: conference.id).present?
  end

  # Returns the purchased ticket
  # ====Returns
  # * +TicketUser::ActiveRecord_Relation+ -> user
  def ticket(id)
    ticket_purchases.where(ticket_id: id).first
  end

  def supports? conference
    ticket_purchases.find_by(conference_id: conference.id).present?
  end

  def self.for_ichain_username(username, attributes)
    user = find_by(username: username)

    raise UserDisabled if user && user.is_disabled

    if user
      user.update_attributes(email: attributes[:email])
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

  def setup_role
    if User.count == 1 && User.first.email == 'deleted@localhost.osem'
      self.is_admin = true
    end
  end

  # Gets the roles of the user, groups them by role.name and returns the resource(s) of each role
  # ====Returns
  # * +Hash+ * ->  e.g. 'organizer' =>  "(conf1, conf2)"
  def get_roles
    result = {}
    Role::ACTIONABLES.each do |role|
      resources = self.roles.where(name: role.parameterize.underscore).map{ |myrole| Conference.find(myrole.resource_id).short_title }.join ', '
      result[role.parameterize.underscore] = "(#{ resources })" unless resources.blank?
    end
    result
  end

  def self.prepare(params)
    email = params['email']
    user = User.where(email: email).first_or_initialize

    # If there is a new user, add the necessary attributes
    if user.new_record?
      user.password = Devise.friendly_token[0, 20]
      user.skip_confirmation!
      user.attributes = params
    end

    user
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

  def attending_conference?(conference)
    Registration.where(conference_id: conference.id,
                       user_id: id).count
  end

  def proposals(conference)
    events.where('conference_id = ? AND event_users.event_role=?', conference.id, 'submitter')
  end

  def proposal_count(conference)
    proposals(conference).count
  end

  def biography_word_count
    if biography.nil?
      0
    else
      biography.split.size
    end
  end

  private

  def biography_limit
    errors.add(:abstract, 'cannot have more than 150 words') if biography &&
                                                                biography.split.size > 150
  end
end
