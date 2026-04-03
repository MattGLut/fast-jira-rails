class PrLink < ApplicationRecord
  enum :status, {
    open: 0,
    merged: 1,
    closed: 2
  }, default: :open

  belongs_to :ticket
  belongs_to :user

  validates :url, presence: true,
                  format: { with: /\Ahttps?:\/\/\S+\z/i, message: 'must be a valid http or https URL' }
  validates :title, presence: true
end
