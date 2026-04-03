class TicketPolicy < ApplicationPolicy
  def index?
    return true if admin?

    member_of_project?(project)
  end

  def show?
    admin? || member_of_project?(record.project)
  end

  def create?
    admin? || member_of_project?(record.project)
  end

  def update?
    return true if admin? || manager_of_project?(record.project)

    same_user?(record.reporter) || same_user?(record.assignee)
  end

  def destroy?
    admin? || manager_of_project?(record.project)
  end

  def assign?
    admin? || member_of_project?(record.project)
  end

  def transition?
    return true if admin? || manager_of_project?(record.project)

    same_user?(record.assignee)
  end

  class Scope < Scope
    def resolve
      return scope.none unless user
      return scope.all if user.admin?

      scope.joins(project: :project_memberships).where(project_memberships: { user_id: user.id }).distinct
    end
  end

  private

  def project
    record.respond_to?(:project) ? record.project : nil
  end
end
