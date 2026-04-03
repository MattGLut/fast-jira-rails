class ApiToken < ApplicationRecord
  belongs_to :user

  has_secure_token :token, length: 36

  validates :name, presence: true

  scope :active, -> { where(active: true) }
end
