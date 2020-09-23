# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
    #
    user ||= User.new # guest user
    alias_action :update, :create, :edit, :complete, :save_and_exit, :to => :modify

    if user.role?(:admin)
      can :manage, :all
    elsif user.role?(:user)
      can :read, [Experiment]
      can :modify, Submission do |submission|
        submission.try(:user) == user  #limits submissions to only the creator of the submission
      end

      cannot [:pending, :active, :destroy_submission], Submission
      cannot :manage, [Scatter]

      if user.role?(:author)
        can :manage, News do |article|
          article.try(:user) == user
        end
      end
    elsif user.role?(:reviewer)
      can :read
      cannot [:pending, :active, :destroy_submission], Submission
      cannot :manage, [Scatter]
    end
  end
end
