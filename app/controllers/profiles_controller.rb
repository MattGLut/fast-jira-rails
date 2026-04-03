class ProfilesController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  helper_method :role_badge_class, :activity_description

  def show
    @user = current_user
    @project_memberships = @user.project_memberships.includes(:project).sort_by { |membership| membership.project.name }

    @tickets_created_count = @user.tickets.count
    @tickets_assigned_count = @user.assigned_tickets.count
    @comments_count = @user.comments.count

    @recent_activity_logs = ActivityLog.includes(:ticket).where(user: @user).order(created_at: :desc).limit(10)
    @api_tokens = @user.admin? ? @user.api_tokens.order(created_at: :desc) : []
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      flash.now[:alert] = "Please review the highlighted fields."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name)
  end

  def role_badge_class(role)
    case role.to_s
    when "admin"
      "border-red-400/40 bg-red-500/20 text-red-200"
    when "project_manager"
      "border-amber-400/40 bg-amber-500/20 text-amber-200"
    else
      "border-blue-400/40 bg-blue-500/20 text-blue-200"
    end
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
