class TicketRelationship < ApplicationRecord
  enum :relationship_type, {
    blocks: 0,
    is_blocked_by: 1,
    relates_to: 2,
    duplicates: 3
  }

  belongs_to :source_ticket, class_name: 'Ticket', inverse_of: :source_relationships
  belongs_to :target_ticket, class_name: 'Ticket', inverse_of: :target_relationships

  validates :relationship_type, presence: true
  validates :relationship_type, uniqueness: { scope: %i[source_ticket_id target_ticket_id] }
  validate :cannot_reference_same_ticket

  private

  def cannot_reference_same_ticket
    return unless source_ticket_id.present? && source_ticket_id == target_ticket_id

    errors.add(:target_ticket, 'cannot reference the same ticket as source')
  end
end
