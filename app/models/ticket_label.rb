class TicketLabel < ApplicationRecord
  belongs_to :ticket
  belongs_to :label

  validates :label_id, uniqueness: { scope: :ticket_id }
end
