class Ability
  include CanCan::Ability

  def initialize(user)
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    # Order Abilities
    # (Check https://github.com/CanCanCommunity/cancancan/wiki/Ability-Precedence)

    user ||= User.new # guest user (not logged in)

    # Check roles of user, using rolify. Role name is *case sensitive*
    # user.is_organizer? or user.has_role? :organizer
    # user.is_cfp_of? Conference or user.has_role? :cfp, Conference
    # user.is_info_desk_of? Conference
    # user.is_volunteer_coordinator_of? Conference
    # user.is_attendee_of? Conference
    # The following is wrong because a user will only have 'cfp' role for a specific conference
    # user.is_cfp? # This is always false

    # Ids of all the conferences for which the user has an 'organizer' role
    conf_ids_for_organizer =
        Conference.with_role(:organizer, user).pluck(:id) unless user.new_record?
    # Ids of the venues of the conference for which (conferences) the user has an 'organizer' role
    conf_ids_for_organizer_venue =
        Conference.with_role(:organizer, user).pluck(:venue_id) unless user.new_record?
    # Ids of all the conferences for which the user has a 'cfp' role
    conf_ids_for_cfp =
        Conference.with_role(:cfp, user).pluck(:id) unless user.new_record?
    # Ids of all the conferences for which the user has an 'info_desk' role
    conf_ids_for_info_desk =
        Conference.with_role(:info_desk, user).pluck(:id) unless user.new_record?
    # Ids of all the conferences for which the user has a 'volunteer_coordinator' role
    conf_ids_for_volunteer_coordinator =
        Conference.with_role(:volunteer_coordinator, user).pluck(:id) unless user.new_record?

    # Abilities for signed in users
    unless user.new_record?
      # Can manage any conference for which user is organizer
      # We need this so that the user menus will properly display admin options
      can :manage, Conference, id: Conference.with_role(:organizer, user).map(&:id)

      # Conference Registration
      can :manage, Registration

      # Proposals
      # Users can edit their own proposals
      # Organizer and CfP team can edit any proposal they want

      # Can manage an event if the user is a speaker or a submitter of that event
      can :manage, Event do |event|
        event.event_users.where(:user_id => user.id).present?
      end

      # Also an organizer can manage that Event
      # With the following ability organizers can access the event/proposal directly from
      # the same link as submitters: /conference/conference_id/proposal/id/edit
      can :manage, Event, conference_id: Conference.with_role(:organizer, user).map(&:id)
      can :manage, Event, conference_id: Conference.with_role(:cfp, user).map(&:id)

      can :create, Event
      can :manage, EventAttachment do |ea|
        Event.find(ea.event_id).event_users.where(user_id: user.id).present?
      end
      can :create, EventAttachment
    end

    # Abilities for everyone, even guests (not logged in users)
    can :show, Conference#, make_conference_public: true
    can :show, Event # if confirmed...?
    can :index, :schedule # show?

    ## Authorization for admins
    if user.is_admin # is_admin is an attribute of User
      can :create, Conference
      can :index, Conference # this will allow the Conference to appear in the menu
      can :view, Conference # for /admin/conference overview
      can :manage, User # to make other users admins
    end

    ## Authorization for ORGANIZER
    # If a user is organizer of a conference, they can manage everything related to this conference

    if user.has_role? :organizer, :any
      can :manage, :all, conference_id: conf_ids_for_organizer

      # Registrations controller authorizes conference resource too, so we don't have to worry about
      # accessing the new registration page of a conference we don't have access to
      can :create, Registration, conference_id: conf_ids_for_organizer

      # Override previous can because
      # Models Conference, Venue, User, Schedule do not have a 'conference_id' attribute
      cannot :manage, Conference
      cannot :manage, Venue
      cannot :manage, User
      cannot :manage, :schedule
      can :manage, :schedule

      # Authorize explicitely, so that it doesn't look for a 'conference_id'
      can :manage, :volunteer

      # Authorize Conference by its 'id' attribute
      can :manage, Conference, id: conf_ids_for_organizer
      # Authorize venues of conferences, which user can manage
      can :manage, Venue, id: conf_ids_for_organizer_venue
      # id: Conference.where(id: conf_ids_for_organizer).map(&:venue_id)
      # User can view the admin 'users' page if he is an organizer for any conference
      can :manage, User if user.has_role?('organizer', :any)
      # To assign roles to users
      # can :manage, Role, resource_id: conf_ids_for_organizer
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
      can :create, Registration, conference_id: conf_ids_for_info_desk

      can :index, User
    end

    ## Authorization for Volunteer Coordinator
    if user.has_role? :volunteer_coordinator, :any
      can [:index, :show], Conference, id: conf_ids_for_volunteer_coordinator
      can :manage, Vposition, conference_id: conf_ids_for_volunteer_coordinator
      can :manage, Vday, conference_id: conf_ids_for_volunteer_coordinator
      can :manage, :volunteer
    end
  end
end
