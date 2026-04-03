class NotificationsController < ApplicationController
  PER_PAGE = 20

  def index
    @page = [params.fetch(:page, 1).to_i, 1].max
    scoped_notifications = policy_scope(Notification).includes(:actor, :ticket).order(created_at: :desc)
    @total_count = scoped_notifications.count
    @notifications = scoped_notifications.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @has_previous_page = @page > 1
    @has_next_page = (@page * PER_PAGE) < @total_count
  end

  def mark_as_read
    @notification = policy_scope(Notification).find(params[:id])
    authorize @notification, :update?

    @notification.update(read: true) unless @notification.read?
    load_notification_dropdown

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: notifications_path, notice: "Notification marked as read." }
      format.json { render json: { ok: true, unread_count: @unread_notifications_count } }
    end
  end

  def mark_all_as_read
    authorize Notification.new(recipient: current_user), :update?

    policy_scope(Notification).where(read: false).update_all(read: true, updated_at: Time.current)
    load_notification_dropdown

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: notifications_path, notice: "All notifications marked as read." }
      format.json { render json: { ok: true, unread_count: @unread_notifications_count } }
    end
  end

  private

  def load_notification_dropdown
    @recent_notifications = policy_scope(Notification).includes(:actor, :ticket).order(created_at: :desc).limit(10)
    @unread_notifications_count = policy_scope(Notification).where(read: false).count
  end
end
