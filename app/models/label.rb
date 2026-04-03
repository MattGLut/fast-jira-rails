class Label < ApplicationRecord
  belongs_to :project

  has_many :ticket_labels, dependent: :destroy
  has_many :tickets, through: :ticket_labels

  validates :name, presence: true, uniqueness: { scope: :project_id }
  validates :color, presence: true,
                    format: { with: /\A#(?:[A-Fa-f0-9]{3}|[A-Fa-f0-9]{6})\z/, message: 'must be a valid hex color' }
end
