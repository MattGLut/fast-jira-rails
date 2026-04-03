class TicketsController < ApplicationController
  before_action :set_project, only: %i[new create]
  before_action :set_ticket, only: %i[show edit update destroy transition assign reorder]

  def show
    authorize @ticket
    @comments = policy_scope(@ticket.comments).includes(:user).order(created_at: :asc)
    @activity_logs = ActivityLog.includes(:user).where(ticket: @ticket).order(created_at: :desc)
    @pr_links = policy_scope(@ticket.pr_links).includes(:user).order(created_at: :desc)
    @project_members = @ticket.project.members.order(:first_name, :last_name)
    @available_labels = policy_scope(@ticket.project.labels).order(:name)
    @relationships = TicketRelationship.includes(:source_ticket, :target_ticket)
      .where("source_ticket_id = :id OR target_ticket_id = :id", id: @ticket.id)
      .order(created_at: :desc)

    @comment = @ticket.comments.new
    @pr_link = @ticket.pr_links.new
    @ticket_relationship = TicketRelationship.new
  end

  def new
    @ticket = @project.tickets.new(ticket_type: :task, priority: :medium, status: :todo)
    authorize @ticket
    load_form_collections
  end

  def create
    @ticket = @project.tickets.new(ticket_params)
    @ticket.reporter = current_user
    authorize @ticket

    if @ticket.save
      create_activity(@ticket, "created", nil, nil, nil)
      redirect_to ticket_path(@ticket), notice: "Ticket created successfully."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @ticket
    load_form_collections
  end

  def update
    authorize @ticket
    previous = @ticket.attributes.slice("status", "priority", "assignee_id", "title", "description", "ticket_type", "story_points", "due_date")

    if @ticket.update(ticket_params)
      create_update_activities(previous)
      redirect_to ticket_path(@ticket), notice: "Ticket updated successfully."
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @ticket
    project = @ticket.project
    @ticket.destroy
    redirect_to board_project_path(project), notice: "Ticket deleted."
  end

  def my_tickets
    authorize Ticket, :index?
    @tickets = policy_scope(Ticket).includes(:project, :assignee, :reporter).where(assignee: current_user).order(updated_at: :desc)
  end

  def transition
    authorize @ticket, :transition?
    new_status = params[:status].to_s

    return render_invalid_status unless Ticket.statuses.key?(new_status)

    old_status = @ticket.status
    if @ticket.update(status: new_status)
      create_activity(@ticket, "status_changed", "status", old_status, new_status)
      NotificationService.status_changed(@ticket, current_user, old_status, new_status)

      # Broadcast board move to OTHER browsers after responding to originator.
      # The originator gets the turbo_stream response (or SortableJS handles it);
      # the broadcast updates everyone else's board in real time.
      @ticket.broadcast_board_move if old_status != new_status

      respond_to do |format|
        format.turbo_stream
        format.json { render json: { ok: true } }
        format.html { redirect_to board_project_path(@ticket.project), notice: "Ticket moved to #{new_status.humanize}." }
      end
    else
      render json: { error: @ticket.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def reorder
    authorize @ticket, :transition?
    new_status = params[:status].to_s
    new_position = params[:position].to_i

    return render_invalid_status unless Ticket.statuses.key?(new_status)

    old_status = @ticket.status
    status_changed = old_status != new_status

    ActiveRecord::Base.transaction do
      if status_changed
        @ticket.update!(status: new_status, position: new_position)
        reposition_siblings(@ticket)
        compact_column_positions(@ticket.project, old_status)
        create_activity(@ticket, "status_changed", "status", old_status, new_status)
        NotificationService.status_changed(@ticket, current_user, old_status, new_status)
      else
        @ticket.update!(position: new_position)
        reposition_siblings(@ticket)
      end
    end

    @ticket.broadcast_column_reorder
    if status_changed
      Turbo::StreamsChannel.broadcast_replace_to(
        "project_#{@ticket.project_id}_board",
        target: "kanban_column_#{old_status}_cards",
        partial: "projects/kanban_column_cards",
        locals: { tickets: @ticket.project.tickets.where(status: old_status).positioned, status: old_status }
      )
    end

    render json: { ok: true }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
  end

  def assign
    authorize @ticket, :assign?

    assignee_id = params[:assignee_id].presence
    assignee = if assignee_id.present?
      @ticket.project.members.find_by(id: assignee_id)
    end

    return render json: { error: "Invalid assignee" }, status: :unprocessable_entity if assignee_id.present? && assignee.nil?

    old_assignee = @ticket.assignee&.email
    if @ticket.update(assignee: assignee)
      create_activity(@ticket, "assignee_changed", "assignee", old_assignee, assignee&.email || "Unassigned")
      NotificationService.ticket_assigned(@ticket, current_user)
      redirect_to ticket_path(@ticket), notice: "Assignee updated successfully."
    else
      redirect_to ticket_path(@ticket), alert: @ticket.errors.full_messages.to_sentence
    end
  end

  private

  def set_project
    @project = policy_scope(Project).find(params[:project_id])
  end

  def set_ticket
    @ticket = policy_scope(Ticket).includes(:project, :labels).find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:title, :description, :status, :priority, :ticket_type, :story_points, :due_date, :assignee_id,
                                   label_ids: [])
  end

  def load_form_collections
    project = @ticket.project
    @project_members = project.members.order(:first_name, :last_name)
    @labels = policy_scope(project.labels).order(:name)
  end

  def create_activity(ticket, action, field_changed, old_value, new_value)
    ActivityLog.create!(
      ticket: ticket,
      user: current_user,
      action: action,
      field_changed: field_changed,
      old_value: old_value,
      new_value: new_value
    )
  end

  def create_update_activities(previous)
    tracked_fields = {
      "status" => "status",
      "priority" => "priority",
      "assignee_id" => "assignee",
      "title" => "title",
      "description" => "description",
      "ticket_type" => "ticket_type",
      "story_points" => "story_points",
      "due_date" => "due_date"
    }

    tracked_fields.each do |attribute, field_name|
      before_value = previous[attribute]
      after_value = @ticket.public_send(attribute)
      next if before_value.to_s == after_value.to_s

      create_activity(@ticket, "updated", field_name, before_value&.to_s, after_value&.to_s)
    end
  end

  def reposition_siblings(ticket)
    siblings = ticket.project.tickets
                     .where(status: ticket.status)
                     .where.not(id: ticket.id)
                     .order(position: :asc, created_at: :asc)

    siblings.each_with_index do |sibling, index|
      new_pos = index >= ticket.position ? index + 1 : index
      sibling.update_column(:position, new_pos) if sibling.position != new_pos
    end
  end

  def compact_column_positions(project, status)
    project.tickets.where(status: status).order(position: :asc, created_at: :asc).each_with_index do |ticket, index|
      ticket.update_column(:position, index) if ticket.position != index
    end
  end

  def render_invalid_status
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash"), status: :unprocessable_entity }
      format.json { render json: { error: "Invalid status" }, status: :unprocessable_entity }
      format.html { redirect_to board_project_path(@ticket.project), alert: "Invalid status" }
    end
  end
end
