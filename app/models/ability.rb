# frozen_string_literal: true

# cancan ability settings
class Ability
  include CanCan::Ability

  def initialize(user)
    # permissions for every user, even if not logged in
    can :read, Entry
    # additional permissions for logged in members
    return unless user.present?

    can :read, Profile
    can :update, Profile, member: user
    can :manage, Vote, member: user
    can %i[new create update destroy], Entry, member: user
    can %i[read update], Notification, recipient: user
  end
end
