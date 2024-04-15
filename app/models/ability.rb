# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(account)
    if account.present?
      can :manage, Post
      can :manage, Favorite
      if account.admin?
        can :manage, :all
      end
    end
  end
end
