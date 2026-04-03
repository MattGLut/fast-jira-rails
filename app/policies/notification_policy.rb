class NotificationPolicy < ApplicationPolicy
  def index?
    same_user?(record.recipient)
  end

  def show?
    same_user?(record.recipient)
  end

  def create?
    false
  end

  def update?
    same_user?(record.recipient)
  end

  def destroy?
    same_user?(record.recipient)
  end

  class Scope < Scope
    def resolve
      return scope.none unless user

      scope.where(recipient_id: user.id)
    end
  end
end
