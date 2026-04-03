class CommentPolicy < ApplicationPolicy
  def index?
    member_of_project?(record.ticket.project)
  end

  def show?
    member_of_project?(record.ticket.project)
  end

  def create?
    member_of_project?(record.ticket.project)
  end

  def update?
    admin? || same_user?(record.user)
  end

  def destroy?
    admin? || same_user?(record.user)
  end

  class Scope < Scope
    def resolve
      return scope.none unless user
      return scope.all if user.admin?

      scope.joins(ticket: { project: :project_memberships }).where(project_memberships: { user_id: user.id }).distinct
    end
  end
end
