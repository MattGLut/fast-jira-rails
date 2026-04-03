class LabelPolicy < ApplicationPolicy
  def index?
    member_of_project?(record.project)
  end

  def show?
    member_of_project?(record.project)
  end

  def create?
    admin? || manager_of_project?(record.project)
  end

  def settings?
    create?
  end

  def update?
    admin? || manager_of_project?(record.project)
  end

  def destroy?
    admin? || manager_of_project?(record.project)
  end

  class Scope < Scope
    def resolve
      return scope.none unless user
      return scope.all if user.admin?

      scope.joins(project: :project_memberships).where(project_memberships: { user_id: user.id }).distinct
    end
  end
end
