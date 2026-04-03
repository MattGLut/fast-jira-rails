class ProjectMembership < ApplicationRecord
  enum :role, {
    member: 0,
    manager: 1
  }, default: :member

  belongs_to :project
  belongs_to :user

  validates :user_id, uniqueness: { scope: :project_id }
end
