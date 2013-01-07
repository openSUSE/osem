class AdminAbility
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new # for guest
    @user.get_roles.each { |role| send(role.name.downcase) }
  end

  def organizer
    can :manage, Event
  end

  def admin
    organizer
    can :manage, :all
  end
end
