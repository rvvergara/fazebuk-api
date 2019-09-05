# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  def update?
    @record.postable_param == @record.postable
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
