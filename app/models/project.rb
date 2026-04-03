class Project < ApplicationRecord
  has_many :project_memberships, dependent: :destroy
  has_many :members, through: :project_memberships, source: :user
  has_many :tickets, dependent: :destroy
  has_many :labels, dependent: :destroy

  validates :name, presence: true
  validates :key, presence: true, uniqueness: true,
                  format: { with: /\A[A-Z]{2,6}\z/, message: 'must be 2-6 uppercase letters' }
end
