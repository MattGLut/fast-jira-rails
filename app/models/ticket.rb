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

  before_create :assign_ticket_number

  def key
    "#{project.key}-#{ticket_number}"
  end

  private

  def assign_ticket_number
    project.with_lock do
      project.increment!(:ticket_sequence)
      self.ticket_number = project.ticket_sequence
    end
  end
end
