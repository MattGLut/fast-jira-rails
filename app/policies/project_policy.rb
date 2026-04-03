class ProjectPolicy < ApplicationPolicy
  def index?
    authenticated?
  end

  def show?
    admin? || member_of_project?(record)
  end

  def create?
    admin? || project_manager?
  end

  def update?
    admin? || manager_of_project?(record)
  end

  def destroy?
    admin?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user
      return scope.all if user.admin?

      scope.joins(:project_memberships).where(project_memberships: { user_id: user.id }).distinct
    end
  end
end
