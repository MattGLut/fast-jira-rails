class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    developer: 0,
    project_manager: 1,
    admin: 2
  }, default: :developer

  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships
  has_many :tickets, foreign_key: :reporter_id, inverse_of: :reporter, dependent: :nullify
  has_many :assigned_tickets, class_name: 'Ticket', foreign_key: :assignee_id, inverse_of: :assignee,
                              dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :notifications, class_name: 'Notification', foreign_key: :recipient_id, inverse_of: :recipient,
                           dependent: :destroy
  has_many :api_tokens, dependent: :destroy
end
