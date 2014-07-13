class AdminAbility
  include CanCan::Ability

  def initialize(user)
    # Check roles of user, using rolify. Role name is *case sensitive*
    # user.is_organizer? or user.has_role? :organizer
    # user.is_cfp_of? Conference or user.has_role? :cfp, Conference
    # user.is_info_desk_of? Conference
    # user.is_volunteer_coordinator_of? Conference
    # user.is_attendee_of? Conference
    # The following is wrong because a user will only have 'cfp' role for a specific conference
    # user.is_cfp? # This is always false

    user ||= User.new # for guest

    if user.new_record?
      cannot :manage, :all
    end

    # Ids of all the conferences for which the user has an 'organizer' role
    conf_ids_for_organizer =
        Conference.with_role(:organizer, user).pluck(:id) unless user.new_record?
    # Ids of all the conferences for which the user has a 'cfp' role
    conf_ids_for_cfp =
        Conference.with_role(:cfp, user).pluck(:id) unless user.new_record?
    # Ids of all the conferences for which the user has an 'info_desk' role
    conf_ids_for_info_desk =
        Conference.with_role(:info_desk, user).pluck(:id) unless user.new_record?
    # Ids of all the conferences for which the user has a 'volunteer_coordinator' role
    conf_ids_for_volunteer_coordinator =
        Conference.with_role(:volunteer_coordinator, user).pluck(:id) unless user.new_record?

    ## Authorization for ORGANIZER
    # If a user is organizer of a conference, they can manage everything related to this conference

    if user.has_role? :organizer, :any
      can :manage, :all, conference_id: conf_ids_for_organizer

      # Registrations controller authorizes conference resource too, so we don't have to worry about
      # accessing the new registration page of a conference we don't have access to
      can :create, Registration

      # Override previous can because
      # Models Conference, Venue, User, Schedule do not have a 'conference_id' attribute
      cannot :manage, Conference
      cannot :manage, Venue
      cannot :manage, User
      cannot :manage, :schedule
      can :manage, :schedule

#       cannot :manage, Registration
#       can :manage, Registration, conference: { id: conf_ids_for_organizer}
      # Authorize explicitely, so that it doesn't look for a 'conference_id'
      can :manage, :volunteer

      # Authorize Conference by its 'id' attribute
      can :manage, Conference, id: conf_ids_for_organizer
      # Authorize venues of conferences, which user can manage
      can :manage, Venue, conference: { id: conf_ids_for_organizer }
      # id: Conference.where(id: conf_ids_for_organizer).map(&:venue_id)
      # User can view the admin 'users' page if he is an organizer for any conference
      can :manage, User if user.has_role?('organizer', :any)
      # To assign roles to users
      # can :manage, Role, resource_id: conf_ids_for_organizer
    end

    if user.is_organizer? # A user can have 'organizer' role not associated to specific conference
      can :create, Conference
      # Can manage /admin/conference # any organizer of any conference and anyone who can create a conf can view the /admin/conference
    end

    ## Authorization for CfP
    # A user can manage events of the conference, for which conference the user has a 'cfp' role
    if user.has_role? :cfp, :any
      # Can view dashboard for specific conference (show) and for all conference (index)
      can [:index, :show], Conference, id: conf_ids_for_cfp
      can :manage, Event, conference_id: conf_ids_for_cfp
      can :manage, CallForPapers, conference_id: conf_ids_for_cfp
      can :manage, EventType, conference_id: conf_ids_for_cfp
      can :manage, Track, conference_id: conf_ids_for_cfp
      can :manage, DifficultyLevel, conference_id: conf_ids_for_cfp
      can :manage, :schedule

      can :manage, EmailSettings, conference_id: conf_ids_for_cfp
      can :index, User
    end

    ## Authorization for Info Desk
    if user.has_role? :info_desk, :any
      can [:index, :show], Conference, id: conf_ids_for_info_desk
      can :manage, Registration, conference_id: conf_ids_for_info_desk
      can :manage, Question, conference_id: conf_ids_for_info_desk

      # Previously we authorized Registrations of a specific conference, but that doesn't work
      # if we want to create a new one, which does not belong to any conference yet
      # Registrations controller authorizes conference resource too, so we don't have to worry about
      # accessing the new registration page of a conference we don't have access to
      can :create, Registration

      can :index, User
    end

    ## Authorization for Volunteer Coordinator
    if user.has_role? :volunteer_coordinator, :any
      can [:index, :show], Conference, id: conf_ids_for_volunteer_coordinator
      can :manage, Vposition, conference_id: conf_ids_for_volunteer_coordinator
      can :manage, Vday, conference_id: conf_ids_for_volunteer_coordinator
      can :manage, :volunteer
    end

    # Allow access to event_attachments that belong to events (via event_id), which
    # events belong to a conference (via conference_id) that has an organizer role for current user
#     can :manage, EventAttachment, event_id: (Event.where(conference_id: conf_ids_for_organizer).pluck(:id))
  end
end
