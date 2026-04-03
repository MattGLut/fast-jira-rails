# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end

  private

  def authenticated?
    user.present?
  end

  def admin?
    user&.admin?
  end

  def project_manager?
    user&.project_manager?
  end

  def member_of_project?(project)
    return false unless authenticated? && project
    return true if admin?

    project.project_memberships.exists?(user_id: user.id)
  end

  def manager_of_project?(project)
    return false unless authenticated? && project
    return true if admin?

    project.project_memberships.exists?(user_id: user.id, role: ProjectMembership.roles[:manager])
  end

  def same_user?(other_user)
    authenticated? && other_user.present? && user.id == other_user.id
  end
end
