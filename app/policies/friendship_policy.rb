# frozen_string_literal: true

class FriendshipPolicy < ApplicationPolicy
  def update?
    @user == @record.passive_friend
  end

  def destroy?
    @user == @record.passive_friend ||
      @user == @record.active_friend
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
