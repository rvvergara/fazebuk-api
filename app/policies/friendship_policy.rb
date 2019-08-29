# frozen_string_literal: true

class FriendshipPolicy < ApplicationPolicy
  class Scope < Scope
    def update?
      @user == @record.passive_friend
    end

    def resolve
      scope.all
    end
  end
end
