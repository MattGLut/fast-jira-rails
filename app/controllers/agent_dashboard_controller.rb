class AgentDashboardController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  TIMELINE_PAGE_SIZE = 30

  def index
    @agents = ApiToken.includes(:user).order(active: :desc, name: :asc)

    agent_user_ids = @agents.map(&:user_id).uniq
    today_range = Time.zone.today.all_day

    assigned_scope = Ticket.includes(:project).where(assignee_id: agent_user_ids).where.not(status: :done)
    completed_scope = Ticket.where(assignee_id: agent_user_ids, status: :done)
    agent_comments_scope = Comment.where(user_id: agent_user_ids, agent_authored: true)
    pr_links_scope = PrLink.where(user_id: agent_user_ids)
    activity_logs_scope = ActivityLog.where(user_id: agent_user_ids)

    assigned_counts = assigned_scope.group(:assignee_id).count
    completed_counts = completed_scope.group(:assignee_id).count
    comment_counts = agent_comments_scope.group(:user_id).count
    pr_counts = pr_links_scope.group(:user_id).count
    assigned_tickets_by_user = assigned_scope.order(updated_at: :desc).group_by(&:assignee_id)

    last_comment_by_user = agent_comments_scope.group(:user_id).maximum(:created_at)
    last_activity_log_by_user = activity_logs_scope.group(:user_id).maximum(:created_at)

    @active_agents_count = @agents.count(&:active?)
    @tickets_in_progress_count = assigned_scope.count
    @prs_submitted_today = pr_links_scope.where(created_at: today_range).count
    @comments_posted_today = agent_comments_scope.where(created_at: today_range).count

    @agent_rows = @agents.map do |agent|
      user_id = agent.user_id
      last_activity_at = [last_comment_by_user[user_id], last_activity_log_by_user[user_id]].compact.max
      assigned_tickets = assigned_tickets_by_user.fetch(user_id, [])

      {
        token: agent,
        user: agent.user,
        assigned_count: assigned_counts.fetch(user_id, 0),
        completed_count: completed_counts.fetch(user_id, 0),
        comment_count: comment_counts.fetch(user_id, 0),
        pr_count: pr_counts.fetch(user_id, 0),
        last_activity_at: last_activity_at,
        assigned_tickets_preview: assigned_tickets.first(3),
        assigned_tickets_remaining: [assigned_tickets.size - 3, 0].max
      }
    end
  end

  def show
    @agent = ApiToken.includes(:user).find(params[:id])
    @user = @agent.user

    @assigned_tickets = Ticket.includes(:project).where(assignee: @user).where.not(status: :done).order(updated_at: :desc)
    @completed_tickets = Ticket.includes(:project).where(assignee: @user, status: :done).order(updated_at: :desc)
    @recent_pr_links = PrLink.includes(:ticket).where(user: @user).order(created_at: :desc).limit(10)

    @total_assigned_count = Ticket.where(assignee: @user).count
    @completed_count = @completed_tickets.count
    @pr_count = PrLink.where(user: @user).count
    @comment_count = Comment.where(user: @user, agent_authored: true).count

    timeline_events = []

    Comment.includes(:ticket).where(user: @user, agent_authored: true).order(created_at: :desc).limit(20).each do |comment|
      timeline_events << {
        kind: :comment,
        icon: "💬",
        description: "Commented on #{comment.ticket.key}: #{comment.ticket.title}",
        ticket: comment.ticket,
        created_at: comment.created_at,
        record: comment
      }
    end

    ActivityLog.includes(:ticket).where(user: @user).order(created_at: :desc).limit(20).each do |activity_log|
      timeline_events << {
        kind: :activity,
        icon: activity_icon(activity_log),
        description: activity_description(activity_log),
        ticket: activity_log.ticket,
        created_at: activity_log.created_at,
        record: activity_log
      }
    end

    PrLink.includes(:ticket).where(user: @user).order(created_at: :desc).limit(20).each do |pr_link|
      timeline_events << {
        kind: :pr_link,
        icon: "🔗",
        description: "Linked PR for #{pr_link.ticket.key}: #{pr_link.title}",
        ticket: pr_link.ticket,
        created_at: pr_link.created_at,
        record: pr_link
      }
    end

    sorted_timeline = timeline_events.sort_by { |event| event[:created_at] }.reverse
    page = [params.fetch(:page, 1).to_i, 1].max
    start_index = (page - 1) * TIMELINE_PAGE_SIZE

    @timeline_items = sorted_timeline.slice(start_index, TIMELINE_PAGE_SIZE) || []
    @timeline_page = page
    @has_more_timeline = sorted_timeline.size > (start_index + TIMELINE_PAGE_SIZE)
  end

  private

  def activity_icon(activity_log)
    return "👤" if activity_log.field_changed == "assignee"

    "🔄"
  end

  def activity_description(activity_log)
    ticket = activity_log.ticket

    if activity_log.field_changed.present?
      old_value = activity_log.old_value.presence || "—"
      new_value = activity_log.new_value.presence || "—"
      "Updated #{ticket.key} #{activity_log.field_changed.humanize.downcase}: #{old_value} → #{new_value}"
    else
      "Recorded #{activity_log.action.to_s.humanize.downcase} on #{ticket.key}: #{ticket.title}"
    end
  end
end
