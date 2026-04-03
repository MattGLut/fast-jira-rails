class PrLink < ApplicationRecord
  enum :status, {
    open: 0,
    merged: 1,
    closed: 2
  }, default: :open

  belongs_to :ticket
  belongs_to :user

  validates :url, presence: true,
                  format: { with: /\Ahttps?:\/\//i, message: 'must start with http or https' }
  validates :title, presence: true
end
