class Ability
  include CanCan::Ability

  # Initializes the ability class
  def initialize(user)
    user ||= User.new

    if user.new_record?
      not_signed_in
    else
      signed_in(user)
      common_abilities_for_admins(user) if user.roles.any? || user.is_admin?
    end
  end

  # Abilities for not signed in users (guests)
  def not_signed_in
    can [:index, :conferences], Organization
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

    can [:new, :create], Booth do |booth|
      booth.new_record? && booth.conference.program.cfps.for_booths.try(:open?)
    end

    can [:edit, :update, :index, :show], Booth do |booth|
      booth.users.include?(user)
    end

    can [:create, :destroy], Subscription, user_id: user.id

    can [:new, :create], Event do |event|
      event.program.cfp_open? && event.new_record?
    end

    can [:update, :show, :index], Event do |event|
      event.users.include?(user)
    end

    # can manage the commercials of their own events
    can :manage, Commercial, commercialable_type: 'Event', commercialable_id: user.events.pluck(:id)

    can [:destroy], Openid

    can [:new, :create], Track do |track|
      track.new_record? && track.program.cfps.for_tracks.try(:open?)
    end

    can [:index, :show, :restart, :confirm, :withdraw], Track, submitter_id: user.id

    can [:edit, :update], Track do |track|
      user == track.submitter && !(track.accepted? || track.confirmed?)
    end
  end

  # Abilities for users with roles wandering around in non-admin views.
  def common_abilities_for_admins(user)
    can :access, Admin
    can :manage, :all if user.is_admin?

    conf_ids_for_organizer = Conference.with_role(:organizer, user).pluck(:id)
    conf_ids_for_cfp = Conference.with_role(:cfp, user).pluck(:id)
    conf_ids_for_info_desk = Conference.with_role(:info_desk, user).pluck(:id)

    if conf_ids_for_organizer
      # To access splashpage of their conference if it is not public
      can :show, Conference, id: conf_ids_for_organizer
      # To access conference/proposals/registrations
      can :manage, Registration, conference_id: conf_ids_for_organizer
      # To access conference/proposals
      can :manage, Event, program: { conference_id: conf_ids_for_organizer }
      # To access comment link in menu bar
      can :index, Comment, commentable_type: 'Event',
                           commentable_id: Event.where(program_id: Program.where(conference_id: conf_ids_for_organizer).pluck(:id)).pluck(:id)
    end

    if conf_ids_for_cfp
      # To access comment link in menu bar
      can :index, Comment, commentable_type: 'Event',
                           commentable_id: Event.where(program_id: Program.where(conference_id: conf_ids_for_cfp).pluck(:id)).pluck(:id)
      # To access conference/proposals
      can :manage, Event, program: { conference_id: conf_ids_for_cfp }
    end

    if conf_ids_for_info_desk
      # To access conference/proposals/registrations
      can :manage, Registration, conference_id: conf_ids_for_info_desk
    end
  end
end
