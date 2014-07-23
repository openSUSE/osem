class Ability
  include CanCan::Ability

  def initialize(user)
    # guest user (not logged in)
    user ||= User.new
    if user.admin? || user.organizer?
      # An admin can manage everything
      can :manage, :all
    else
      can [:update, :destroy], Event do |event|
        event.users.include?(user)
      end
      can [:create, :read], Event
    end
  end
end
