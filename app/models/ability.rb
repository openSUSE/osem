class Ability
  include CanCan::Ability

  # Initializes the ability class
  def initialize(user)
    # Order Abilities
    # (Check https://github.com/CanCanCommunity/cancancan/wiki/Ability-Precedence)
    # Check roles of user, using rolify. Role name is *case sensitive*
    # user.is_organizer? or user.has_role? :organizer
    # user.is_cfp_of? Conference or user.has_role? :cfp, Conference
    # user.is_info_desk_of? Conference
    # user.is_volunteers_coordinator_of? Conference
    # user.is_attendee_of? Conference
    # The following is wrong because a user will only have 'cfp' role for a specific conference
    # user.is_cfp? # This is always false

    user ||= User.new

    # This is what sets up the different abilities
    if user.new_record?
      not_signed_in
    # Checks if the user does not have any role and is not an admin
    elsif user.roles.any? || user.is_admin
      signed_in_with_roles(user)
    else
      signed_in(user)
    end
  end

  # Abilities for not signed in users (guests)
  def not_signed_in
    can [:index], Organization
    can [:index], Conference
    can [:show], Conference do |conference|
      conference.splashpage && conference.splashpage.public == true
    end
    # Can view the schedule
    can [:schedule, :events], Conference do |conference|
      conference.program.cfp && conference.program.schedule_public
    end

    can :show, Event do |event|
      event.state == 'confirmed'
    end

    # can view Commercials of confirmed Events
    can :show, Commercial, commercialable_type: 'Event', commercialable_id: Event.where(state: 'confirmed').pluck(:id)
    can [:show, :create], User
    unless ENV['OSEM_ICHAIN_ENABLED'] == 'true'
      can :show, Registration do |registration|
        registration.new_record?
      end

      can [:new, :create], Registration do |registration|
        conference = registration.conference
        conference.registration_open? && registration.new_record? && !conference.registration_limit_exceeded?
      end

      can :show, Event do |event|
        event.new_record?
      end

      can [:new, :create], Event do |event|
        event.program.cfp_open? && event.new_record?
      end

      can [:show, :events], Schedule do |schedule|
        schedule.program.schedule_public
      end
    end
  end

  # Abilities for signed in users
  def signed_in(user)
    # Abilities from not_signed_in user are also inherited
    not_signed_in

    can :manage, User, id: user.id

    can :manage, Registration, user_id: user.id

    can [:new, :create], Registration do |registration|
      conference = registration.conference
      conference.registration_open? && !conference.registration_limit_exceeded? || conference.program.speakers.confirmed.include?(user)
    end

    can :index, Organization
    can :index, Ticket
    can :manage, TicketPurchase, user_id: user.id
    can [:new, :create], Payment, user_id: user.id
    can [:index, :show], PhysicalTicket, user: user

    can [:create, :destroy], Subscription, user_id: user.id

    can [:new, :create], Event do |event|
      event.program.cfp_open? && event.new_record?
    end

    can [:update, :show, :delete, :index], Event do |event|
      event.users.include?(user)
    end

    # can manage the commercials of their own events
    can :manage, Commercial, commercialable_type: 'Event', commercialable_id: user.events.pluck(:id)

    can [:destroy], Openid
  end

  # Abilities for signed in users with roles
  def signed_in_with_roles(user)
    # Abilities from not_signed_in and signed_in are also inherited
    signed_in(user)

    signed_in_with_organization_admin_role(user) if user.has_role? :organization_admin, :any
    signed_in_with_organizer_role(user) if user.has_role? :organizer, :any
    signed_in_with_cfp_role(user) if user.has_role? :cfp, :any
    signed_in_with_info_desk_role(user) if user.has_role? :info_desk, :any
    signed_in_with_volunteers_coordinator_role(user) if user.has_role? :volunteers_coordinator, :any

    # for users with any role
    can :access, Admin
    can [:show], Conference
    can :index, Commercial, commercialable_type: 'Conference'
    cannot [:edit, :update, :destroy], Question, global: true
    # for admins
    can :manage, :all if user.is_admin

    # even admin cannot create new users with ICHAIN enabled
    cannot [:new, :create], User if ENV['OSEM_ICHAIN_ENABLED'] == 'true'

    cannot :revert_object, PaperTrail::Version do |version|
      (version.event == 'create' && %w(Conference User Event).include?(version.item_type))
    end

    cannot :revert_attribute, PaperTrail::Version do |version|
      version.event != 'update' || version.item.nil?
    end

    cannot :destroy, Program
    # Do not delete venue, when there are rooms being used
    cannot :destroy, Venue do |venue|
      venue.conference.program.events.where.not(room_id: nil).any?
    end

    # Can't create cfp if there are no available cfp types
    cannot [:new, :create], Cfp do |cfp|
      cfp.program.remaining_cfp_types.empty?
    end
  end

  def signed_in_with_organization_admin_role(user)
    org_ids_for_organization_admin = Organization.with_role(:organization_admin, user).pluck(:id)
    conf_ids_for_organization_admin = Conference.where(organization_id: org_ids_for_organization_admin).pluck(:id)

    can [:read, :update, :destroy], Organization, id: org_ids_for_organization_admin
    can :new, Conference
    can :manage, Conference, organization_id: org_ids_for_organization_admin
    can [:index, :show], Role
    can [:edit, :update], Role do |role|
      role.resource_type == 'Organization' && (org_ids_for_organization_admin.include? role.resource_id)
    end
    signed_in_with_organizer_role(user, conf_ids_for_organization_admin)
  end

  def signed_in_with_organizer_role(user, conf_ids_for_organization_admin = [])
    # ids of all the conferences for which the user has the 'organizer' role and
    # conferences that belong to organizations for which user is 'organization_admin'
    conf_ids = conf_ids_for_organization_admin.concat(Conference.with_role(:organizer, user).pluck(:id)).uniq
    can :manage, Resource, conference_id: conf_ids
    can [:read, :update, :destroy], Conference, id: conf_ids
    can :manage, Splashpage, conference_id: conf_ids
    can :manage, Contact, conference_id: conf_ids
    can :manage, EmailSettings, conference_id: conf_ids
    can :manage, Campaign, conference_id: conf_ids
    can :manage, Target, conference_id: conf_ids
    can :manage, Commercial, commercialable_type: 'Conference',
                             commercialable_id: conf_ids
    can :manage, Registration, conference_id: conf_ids
    can :manage, RegistrationPeriod, conference_id: conf_ids
    can :manage, Question, conference_id: conf_ids
    can :manage, Question do |question|
      !(question.conferences.pluck(:id) & conf_ids).empty?
    end
    can :manage, Vposition, conference_id: conf_ids
    can :manage, Vday, conference_id: conf_ids
    can :manage, Program, conference_id: conf_ids
    can :manage, Schedule, program: { conference_id: conf_ids }
    can :manage, EventSchedule, schedule: { program: { conference_id: conf_ids } }
    can :manage, Cfp, program: { conference_id: conf_ids}
    can :manage, Event, program: { conference_id: conf_ids}
    can :manage, EventType, program: { conference_id: conf_ids}
    can :manage, Track, program: { conference_id: conf_ids}
    can :manage, DifficultyLevel, program: { conference_id: conf_ids}
    can :manage, Commercial, commercialable_type: 'Event',
                             commercialable_id: Event.where(program_id: Program.where(conference_id: conf_ids).pluck(:id)).pluck(:id)
    can :manage, Venue, conference_id: conf_ids
    can :manage, Commercial, commercialable_type: 'Venue',
                             commercialable_id: Venue.where(conference_id: conf_ids).pluck(:id)
    can :manage, Lodging, conference_id: conf_ids
    can :manage, Room, venue: { conference_id: conf_ids}
    can :manage, Sponsor, conference_id: conf_ids
    can :manage, SponsorshipLevel, conference_id: conf_ids
    can :manage, Ticket, conference_id: conf_ids
    can :index, Comment, commentable_type: 'Event',
                         commentable_id: Event.where(program_id: Program.where(conference_id: conf_ids).pluck(:id)).pluck(:id)

    # Abilities for Role (Conference resource)
    can [:index, :show], Role do |role|
      role.resource_type == 'Conference'
    end

    can [:edit, :update, :toggle_user], Role do |role|
      role.resource_type == 'Conference' && (conf_ids.include? role.resource_id)
    end

    can [:index, :revert_object, :revert_attribute], PaperTrail::Version, item_type: 'User'
    can [:index, :revert_object, :revert_attribute], PaperTrail::Version, conference_id: conf_ids
  end

  def signed_in_with_cfp_role(user)
    # ids of all the conferences for which the user has the 'cfp' role
    conf_ids_for_cfp = Conference.with_role(:cfp, user).pluck(:id)

    can [:index, :show, :update], Resource, conference_id: conf_ids_for_cfp
    can :manage, Event, program: { conference_id: conf_ids_for_cfp }
    can :manage, EventType, program: { conference_id: conf_ids_for_cfp }
    can :manage, Track, program: { conference_id: conf_ids_for_cfp }
    can :manage, DifficultyLevel, program: { conference_id: conf_ids_for_cfp }
    can :manage, EmailSettings, conference_id: conf_ids_for_cfp
    can :manage, Schedule, program: { conference_id: conf_ids_for_cfp }
    can :manage, Room, venue: { conference_id: conf_ids_for_cfp }
    can :show, Venue, conference_id: conf_ids_for_cfp
    can :show, Commercial, commercialable_type: 'Venue', commercialable_id: Venue.where(conference_id: conf_ids_for_cfp).pluck(:id)
    can :manage, Cfp, program: { conference_id: conf_ids_for_cfp }
    can :manage, Program, conference_id: conf_ids_for_cfp
    can :manage, Commercial, commercialable_type: 'Event',
                             commercialable_id: Event.where(program_id: Program.where(conference_id: conf_ids_for_cfp).pluck(:id)).pluck(:id)
    can :index, Comment, commentable_type: 'Event',
                         commentable_id: Event.where(program_id: Program.where(conference_id: conf_ids_for_cfp).pluck(:id)).pluck(:id)

    # Abilities for Role (Conference resource)
    can [:index, :show], Role do |role|
      role.resource_type == 'Conference'
    end
    # Can add or remove users from role, when user has that same role for the conference
    # Eg. If you are member of the CfP team, you can add more CfP team members (add users to the role 'CfP')
    can :toggle_user, Role do |role|
      role.resource_type == 'Conference' && role.name == 'cfp' &&
      (Conference.with_role(:cfp, user).pluck(:id).include? role.resource_id)
    end

    can [:index, :revert_object, :revert_attribute], PaperTrail::Version,
        item_type: %w(Event EventType Track DifficultyLevel EmailSettings Room Cfp Program Comment), conference_id: conf_ids_for_cfp
    can [:index, :revert_object, :revert_attribute], PaperTrail::Version,
        ["item_type = 'Commercial' AND conference_id IN (?) AND (object LIKE '%Event%' OR object_changes LIKE '%Event%')", conf_ids_for_cfp] do |version|
      version.item_type == 'Commercial' && conf_ids_for_cfp.include?(version.conference_id) &&
      (version.object.to_s.include?('Event') || version.object_changes.to_s.include?('Event'))
    end
  end

  def signed_in_with_info_desk_role(user)
    # ids of all the conferences for which the user has the 'info_desk' role
    conf_ids_for_info_desk = Conference.with_role(:info_desk, user).pluck(:id)

    can [:index, :show, :update], Resource, conference_id: conf_ids_for_info_desk
    can :manage, Registration, conference_id: conf_ids_for_info_desk
    can :manage, Question, conference_id: conf_ids_for_info_desk
    can :manage, Question do |question|
      !(question.conferences.pluck(:id) & conf_ids_for_info_desk).empty?
    end

    # Abilities for Role (Conference resource)
    can [:index, :show], Role do |role|
      role.resource_type == 'Conference'
    end
    # Can add or remove users from role, when user has that same role for the conference
    # Eg. If you are member of the CfP team, you can add more CfP team members (add users to the role 'CfP')
    can :toggle_user, Role do |role|
      role.resource_type == 'Conference' && role.name == 'info_desk' &&
      (Conference.with_role(:info_desk, user).pluck(:id).include? role.resource_id)
    end

    can [:index, :revert_object, :revert_attribute], PaperTrail::Version, item_type: 'Registration', conference_id: conf_ids_for_info_desk
  end

  def signed_in_with_volunteers_coordinator_role(user)
    # ids of all the conferences for which the user has the 'volunteers_coordinator' role
    conf_ids_for_volunteers_coordinator = Conference.with_role(:volunteers_coordinator, user).pluck(:id)

    can [:index, :show, :update], Resource, conference_id: conf_ids_for_volunteers_coordinator
    can :manage, Vposition, conference_id: conf_ids_for_volunteers_coordinator
    can :manage, Vday, conference_id: conf_ids_for_volunteers_coordinator

    # Abilities for Role (Conference resource)
    can [:index, :show], Role do |role|
      role.resource_type == 'Conference'
    end
    # Can add or remove users from role, when user has that same role for the conference
    # Eg. If you are member of the CfP team, you can add more CfP team members (add users to the role 'CfP')
    can :toggle_user, Role do |role|
      role.resource_type == 'Conference' && role.name == 'volunteers_coordinator' &&
      (Conference.with_role(:volunteers_coordinator, user).pluck(:id).include? role.resource_id)
    end
  end
end
