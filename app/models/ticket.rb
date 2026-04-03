class Ticket < ApplicationRecord
  STORY_POINTS = [1, 2, 3, 5, 8, 13].freeze

  enum :status, {
    todo: 0,
    in_progress: 1,
    code_review: 2,
    qa: 3,
    done: 4
  }, default: :todo

  enum :priority, {
    low: 0,
    medium: 1,
    high: 2,
    critical: 3
  }, default: :medium

  enum :ticket_type, {
    task: 0,
    story: 1,
    bug: 2
  }

  belongs_to :project
  belongs_to :reporter, class_name: 'User', inverse_of: :tickets
  belongs_to :assignee, class_name: 'User', optional: true, inverse_of: :assigned_tickets

  has_many :comments, dependent: :destroy
  has_many :activity_logs, dependent: :destroy
  has_many :pr_links, dependent: :destroy
  has_many :ticket_labels, dependent: :destroy
  has_many :labels, through: :ticket_labels

  has_many :source_relationships, class_name: 'TicketRelationship', foreign_key: :source_ticket_id,
                                  inverse_of: :source_ticket, dependent: :destroy
  has_many :target_relationships, class_name: 'TicketRelationship', foreign_key: :target_ticket_id,
                                  inverse_of: :target_ticket, dependent: :destroy

  validates :title, presence: true
  validates :story_points, inclusion: { in: STORY_POINTS }, allow_nil: true

  scope :positioned, -> { order(position: :asc, created_at: :asc) }

  before_create :assign_ticket_number
  before_create :assign_position
  after_update_commit :broadcast_ticket_update

  def key
    "#{project.key}-#{ticket_number}"
  end

  def broadcast_board_move
    old_status = status_previously_was

    broadcast_column_reorder

    return if old_status.blank? || old_status == status

    Turbo::StreamsChannel.broadcast_replace_to(
      "project_#{project_id}_board",
      target: "kanban_column_#{old_status}_cards",
      partial: "projects/kanban_column_cards",
      locals: { tickets: project.tickets.where(status: old_status).positioned, status: old_status }
    )
  end

  def broadcast_column_reorder
    Turbo::StreamsChannel.broadcast_replace_to(
      "project_#{project_id}_board",
      target: "kanban_column_#{status}_cards",
      partial: "projects/kanban_column_cards",
      locals: { tickets: project.tickets.where(status: status).positioned, status: status }
    )
  end

  private

  def assign_ticket_number
    project.with_lock do
      project.increment!(:ticket_sequence)
      self.ticket_number = project.ticket_sequence
    end
  end

  def assign_position
    max_position = project.tickets.where(status: status).maximum(:position)
    self.position = max_position.nil? ? 0 : max_position + 1
  end

  def broadcast_ticket_update
    # Board broadcasts (remove + append) are handled by the controller
    # to avoid conflicting with the turbo_stream response sent to the
    # originating browser. Only the detail sidebar is broadcast from
    # the model since it uses replace (idempotent).
    broadcast_replace_to "ticket_#{id}",
                         target: "ticket_#{id}_details",
                         partial: "tickets/detail_sidebar",
                         locals: { ticket: self }
  end
end
