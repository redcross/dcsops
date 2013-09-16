class ApiAbility
  include CanCan::Ability

  def initialize(client)
    can :manage, :all
  end
end