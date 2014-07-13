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

    # Abilities per role

    # Abilities for signed in users
    unless user.new_record?
      # Can manage any conference for which user is organizer
      # We need this so that the user menus will properly display admin options
      can :manage, Conference, id: Conference.with_role(:organizer, user).map(&:id)

      # Conference Registration
      can :manage, :conference_registration

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

  end
end
