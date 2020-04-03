# frozen_string_literal: true

class AdminAbility
  include CanCan::Ability

  def initialize(user)
    # Order Abilities
    # (Check https://github.com/CanCanCommunity/cancancan/wiki/Ability-Precedence)
    # Check roles of user, using rolify. Role name is *case sensitive*
    # user.is_organizer? or user.has_cached_role? :organizer
    # user.is_cfp_of? Conference or user.has_cached_role? :cfp, Conference
    # user.is_info_desk_of? Conference
    # user.is_volunteers_coordinator_of? Conference
    # user.is_attendee_of? Conference
    # The following is wrong because a user will only have 'cfp' role for a specific conference
    # user.is_cfp? # This is always false

    user ||= User.new
    signed_in_with_roles(user)
  end

  def common_abilities_for_roles(user)
    can :manage, Registration, user_id: user.id

    can :index, Conference
    can :show, Registration, &:new_record?

    can [:new, :create], Registration do |registration|
      conference = registration.conference
      conference.registration_open? && !conference.registration_limit_exceeded? || conference.program.speakers.confirmed.include?(user)
    end

    can [:index, :admins], Organization
    can :index, Ticket
    can :manage, TicketPurchase, user_id: user.id
    can [:new, :create], Payment, user_id: user.id

    can [:create, :destroy], Subscription, user_id: user.id

    can [:new, :create], Event do |event|
      event.program.cfp_open? && event.new_record?
    end

    # can manage the commercials of their own events
    can :manage, Commercial, commercialable_type: 'Event', commercialable_id: user.events.pluck(:id)

    can [:destroy], Openid
    can :access, Admin
    can :index, Commercial, commercialable_type: 'Conference'
    cannot [:edit, :update, :destroy], Question, global: true
    # for admins
    can :manage, :all if user.is_admin
    # even admin cannot create new users with ICHAIN enabled
    cannot [:new, :create], User if ENV['OSEM_ICHAIN_ENABLED'] == 'true'
    cannot :revert_object, PaperTrail::Version do |version|
      (version.event == 'create' && %w[Conference User Event].include?(version.item_type))
    end
    cannot :revert_attribute, PaperTrail::Version do |version|
      version.event != 'update' || version.item.nil?
    end
    # Can't create cfp if there are no available cfp types
    cannot [:new, :create], Cfp do |cfp|
      cfp.program.remaining_cfp_types.empty?
    end
    cannot :destroy, Program
    # Do not delete venue, when there are rooms being used
    cannot :destroy, Venue do |venue|
      venue.conference.program.events.where.not(room_id: nil).any?
    end

    # Prevent requests for tracks from being destroyed
    cannot :destroy, Track do |track|
      track.self_organized?
    end
    # Can't accept a booth when booth_limit is reached
    cannot :accept, Booth do |booth|
      conference = booth.conference
      conference.maximum_accepted_booths?
    end
  end

  # Abilities for signed in users with roles
  def signed_in_with_roles(user)
    signed_in_with_organization_admin_role(user) if user.has_cached_role? :organization_admin, :any
    signed_in_with_organizer_role(user) if user.has_cached_role? :organizer, :any
    signed_in_with_cfp_role(user) if user.has_cached_role? :cfp, :any
    signed_in_with_info_desk_role(user) if user.has_cached_role? :info_desk, :any
    signed_in_with_volunteers_coordinator_role(user) if user.has_cached_role? :volunteers_coordinator, :any
    signed_in_with_track_organizer_role(user) if user.has_cached_role? :track_organizer, :any
    common_abilities_for_roles(user)
  end

  def signed_in_with_organization_admin_role(user)
    org_ids_for_organization_admin = Organization.with_role(:organization_admin, user).pluck(:id)
    conf_ids_for_organization_admin = Conference.where(organization_id: org_ids_for_organization_admin).pluck(:id)

    can [:read, :update, :destroy, :assign_org_admins, :unassign_org_admins, :admins], Organization, id: org_ids_for_organization_admin
    can :new, Conference
    can :manage, Conference, organization_id: org_ids_for_organization_admin
    can [:index, :show], Role

    can [:index, :revert_object, :revert_attribute], PaperTrail::Version, organization_id: org_ids_for_organization_admin

    signed_in_with_organizer_role(user, conf_ids_for_organization_admin)
  end

  def signed_in_with_organizer_role(user, conf_ids_for_organization_admin = [])
    # ids of all the conferences for which the user has the 'organizer' role and
    # conferences that belong to organizations for which user is 'organization_admin'
    conf_ids = conf_ids_for_organization_admin.concat(Conference.with_role(:organizer, user).pluck(:id)).uniq
    # ids of all the tracks that belong to the programs of the above conferences
    track_ids = Track.joins(:program).where('programs.conference_id IN (?)', conf_ids).pluck(:id)

    can :manage, Resource, conference_id: conf_ids
    can [:read, :update, :destroy], Conference, id: conf_ids
    can :manage, Splashpage, conference_id: conf_ids
    can :manage, Contact, conference_id: conf_ids
    can :manage, EmailSettings, conference_id: conf_ids
    can :manage, Commercial, commercialable_type: 'Conference',
                             commercialable_id:   conf_ids
    can :manage, Registration, conference_id: conf_ids
    can :manage, RegistrationPeriod, conference_id: conf_ids
    can :manage, Booth, conference_id: conf_ids
    can :manage, Question, conference_id: conf_ids
    can :manage, Question do |question|
      !(question.conferences.pluck(:id) & conf_ids).empty?
    end
    can :manage, Vposition, conference_id: conf_ids
    can :manage, Vday, conference_id: conf_ids
    can :manage, Program, conference_id: conf_ids
    can :manage, Schedule, program: { conference_id: conf_ids }
    can :manage, EventSchedule, schedule: { program: { conference_id: conf_ids } }
    can :manage, Cfp, program: { conference_id: conf_ids }
    can :manage, Event, program: { conference_id: conf_ids }
    can :manage, EventType, program: { conference_id: conf_ids }
    can :manage, Track, program: { conference_id: conf_ids }
    can :manage, DifficultyLevel, program: { conference_id: conf_ids }
    can :manage, Commercial, commercialable_type: 'Event',
                             commercialable_id:   Event.where(program_id: Program.where(conference_id: conf_ids).pluck(:id)).pluck(:id)
    can :manage, Venue, conference_id: conf_ids
    can :manage, Commercial, commercialable_type: 'Venue',
                             commercialable_id:   Venue.where(conference_id: conf_ids).pluck(:id)
    can :manage, Lodging, conference_id: conf_ids
    can :manage, Room, venue: { conference_id: conf_ids }
    can :manage, Sponsor, conference_id: conf_ids
    can :manage, SponsorshipLevel, conference_id: conf_ids
    can :manage, Ticket, conference_id: conf_ids
    can :create, TicketScanning do |ticket_scanning|
      conf_id = ticket_scanning.physical_ticket.ticket_purchase.conference_id
      conf_ids.include? conf_id
    end
    can :index, Comment, commentable_type: 'Event',
                         commentable_id:   Event.where(program_id: Program.where(conference_id: conf_ids).pluck(:id)).pluck(:id)

    # Abilities for Role (Conference resource)
    can [:index, :show], Role do |role|
      role.resource_type == 'Conference' || role.resource_type == 'Track'
    end

    can [:edit, :update, :toggle_user], Role do |role|
      role.resource_type == 'Conference' && (conf_ids.include? role.resource_id) ||
        role.resource_type == 'Track' && (track_ids.include? role.resource_id)
    end

    can [:index, :revert_object, :revert_attribute], PaperTrail::Version, item_type: 'User'
    can [:index, :revert_object, :revert_attribute], PaperTrail::Version, conference_id: conf_ids
  end

  def signed_in_with_cfp_role(user)
    # ids of all the conferences for which the user has the 'cfp' role
    conf_ids_for_cfp = Conference.with_role(:cfp, user).pluck(:id)

    can :show, Conference do |conf|
      conf_ids_for_cfp.include?(conf.id)
    end
    can [:index, :show, :update], Resource, conference_id: conf_ids_for_cfp
    can :manage, Booth, conference_id: conf_ids_for_cfp
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
                             commercialable_id:   Event.where(program_id: Program.where(conference_id: conf_ids_for_cfp).pluck(:id)).pluck(:id)
    can :index, Comment, commentable_type: 'Event',
                         commentable_id:   Event.where(program_id: Program.where(conference_id: conf_ids_for_cfp).pluck(:id)).pluck(:id)

    # Abilities for Role (Conference resource)
    can [:index, :show], Role do |role|
      role.resource_type == 'Conference' || role.resource_type == 'Track'
    end
    # Can add or remove users from role, when user has that same role for the conference
    # Eg. If you are member of the CfP team, you can add more CfP team members (add users to the role 'CfP')
    can :toggle_user, Role do |role|
      role.resource_type == 'Conference' && role.name == 'cfp' &&
        (Conference.with_role(:cfp, user).pluck(:id).include? role.resource_id)
    end

    can [:index, :revert_object, :revert_attribute], PaperTrail::Version,
        item_type: %w[Event EventType Track DifficultyLevel EmailSettings Room Cfp Program Comment], conference_id: conf_ids_for_cfp
    can [:index, :revert_object, :revert_attribute], PaperTrail::Version,
        ["item_type = 'Commercial' AND conference_id IN (?) AND (object LIKE '%Event%' OR object_changes LIKE '%Event%')", conf_ids_for_cfp] do |version|
      version.item_type == 'Commercial' && conf_ids_for_cfp.include?(version.conference_id) &&
        (version.object.to_s.include?('Event') || version.object_changes.to_s.include?('Event'))
    end
  end

  def signed_in_with_info_desk_role(user)
    # ids of all the conferences for which the user has the 'info_desk' role
    conf_ids_for_info_desk = Conference.with_role(:info_desk, user).pluck(:id)

    can :show, Conference do |conf|
      conf_ids_for_info_desk.include?(conf.id)
    end
    can [:index, :show, :update], Resource, conference_id: conf_ids_for_info_desk
    can :manage, Registration, conference_id: conf_ids_for_info_desk
    can :manage, Question, conference_id: conf_ids_for_info_desk
    can :manage, Question do |question|
      !(question.conferences.pluck(:id) & conf_ids_for_info_desk).empty?
    end
    can :create, TicketScanning do |ticket_scanning|
      conf_id = ticket_scanning.physical_ticket.ticket_purchase.conference_id
      conf_ids_for_info_desk.include? conf_id
    end

    # Abilities for Role (Conference resource)
    can [:index, :show], Role do |role|
      role.resource_type == 'Conference' || role.resource_type == 'Track'
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

    can :show, Conference do |conf|
      conf_ids_for_volunteers_coordinator.include?(conf.id)
    end
    can [:index, :show, :update], Resource, conference_id: conf_ids_for_volunteers_coordinator
    can :manage, Vposition, conference_id: conf_ids_for_volunteers_coordinator
    can :manage, Vday, conference_id: conf_ids_for_volunteers_coordinator

    # Abilities for Role (Conference resource)
    can [:index, :show], Role do |role|
      role.resource_type == 'Conference' || role.resource_type == 'Track'
    end
    # Can add or remove users from role, when user has that same role for the conference
    # Eg. If you are member of the CfP team, you can add more CfP team members (add users to the role 'CfP')
    can :toggle_user, Role do |role|
      role.resource_type == 'Conference' && role.name == 'volunteers_coordinator' &&
        (Conference.with_role(:volunteers_coordinator, user).pluck(:id).include? role.resource_id)
    end
  end

  def signed_in_with_track_organizer_role(user)
    # ids of all the conferences for which the user has the 'track organizer' role
    conf_ids_for_track_organizer = Track.with_role(:track_organizer, user).joins(:program).pluck(:conference_id)
    # ids of all the tracks for which the user has the 'track_organizer' role
    track_ids_for_track_organizer = Track.with_role(:track_organizer, user).pluck(:id)

    can :show, Conference do |conf|
      conf_ids_for_track_organizer.include?(conf.id)
    end

    # Show Program in the admin sidebar
    can :show, Program, conference_id: conf_ids_for_track_organizer

    # Show Tracks in the admin sidebar
    can :update, Track do |track|
      track.new_record? && conf_ids_for_track_organizer.include?(track.program.conference_id)
    end

    can :manage, Track, id: track_ids_for_track_organizer

    cannot [:edit, :update], Track do |track|
      track.self_organized_and_accepted_or_confirmed?
    end

    # Show Roles in the admin sidebar and allow authorization of the index action
    can [:index, :show], Role do |role|
      role.resource_type == 'Conference' || role.resource_type == 'Track'
    end

    can :toggle_user, Role do |role|
      role.resource_type == 'Track' && track_ids_for_track_organizer.include?(role.resource_id)
    end

    # Show Events in the admin sidebar
    can :update, Event do |event|
      event.new_record? && conf_ids_for_track_organizer.include?(event.program.conference_id)
    end

    can :manage, Event, track_id: track_ids_for_track_organizer
    can :manage, Commercial, commercialable_type: 'Event',
                             commercialable_id:   Event.where(track_id: track_ids_for_track_organizer).pluck(:id)

    # Show Scheduless in the admin sidebar
    can :update, Schedule do |schedule|
      schedule.new_record? && conf_ids_for_track_organizer.include?(schedule.program.conference_id)
    end

    # Show new track schedule button
    can :new, Schedule do |schedule|
      schedule.new_record? && conf_ids_for_track_organizer.include?(schedule.program.conference_id) && schedule.track.try(:new_record?)
    end

    can :manage, Schedule, track_id: track_ids_for_track_organizer
    can :manage, EventSchedule, schedule: { track_id: track_ids_for_track_organizer }
  end
end
