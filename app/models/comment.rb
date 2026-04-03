class Comment < ApplicationRecord
  belongs_to :ticket
  belongs_to :user

  validates :body, presence: true

  after_create_commit :broadcast_new_comment

  private

  def broadcast_new_comment
    broadcast_append_to "ticket_#{ticket_id}_comments",
                        target: "comments_list",
                        partial: "comments/comment",
                        locals: { comment: self, ticket: ticket }
  end
end
