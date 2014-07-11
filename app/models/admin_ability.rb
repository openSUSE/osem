class AdminAbility
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # for guest
    if user.role?('Conference Admin')
      can :manage, :all
    end

  end
end
