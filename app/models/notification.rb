class Notification < ApplicationRecord
  belongs_to :recipient, class_name: 'User', inverse_of: :notifications
  belongs_to :ticket, optional: true
  belongs_to :actor, class_name: 'User'

  validates :message, presence: true

  scope :unread, -> { where(read: false) }
  scope :recent, -> { where(created_at: 30.days.ago..Time.current) }
end
