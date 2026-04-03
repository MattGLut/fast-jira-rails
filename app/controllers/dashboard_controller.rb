class DashboardController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    ticket_scope = policy_scope(Ticket).includes(:project, :assignee, :reporter)

    @status_counts = Ticket.statuses.keys.index_with { |status| ticket_scope.public_send(status).count }
    @recent_tickets = ticket_scope.order(updated_at: :desc).limit(10)
    @assigned_tickets = ticket_scope.where(assignee: current_user).order(updated_at: :desc).limit(8)
    @recent_activity = ActivityLog.includes(:ticket, :user)
      .where(ticket_id: ticket_scope.select(:id))
      .order(created_at: :desc)
      .limit(12)
  end
end
