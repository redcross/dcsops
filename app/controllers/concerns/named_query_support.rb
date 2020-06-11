module NamedQuerySupport
  extend ActiveSupport::Concern

  included do
    before_action :parse_named_query
  end

  def named_query
    return @named_query if defined?(@named_query)
    name = params[:query_name]
    token = params[:query_token]

    if name and token
      @named_query = NamedQuery.find_by name: name, token: token, controller: self.class.to_s, action: params[:action]
    else
      @named_query = nil
    end

    @named_query
  end

  def parse_named_query
    if query = named_query
      params.deep_merge! Rack::Utils.parse_nested_query(query.parameters)
    end
  end

  def require_valid_user!
    return true if named_query
    super
  end

  def current_ability
    return NamedQueryAbility.new if named_query
    super
  end

  class NamedQueryAbility
    include CanCan::Ability

    def initialize
      can :manage, :all
    end
  end

end