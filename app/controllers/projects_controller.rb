class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy board settings]

  def index
    authorize Project
    @projects = policy_scope(Project).includes(:tickets, :project_memberships).order(:name)
  end

  def show
    authorize @project
    @tickets = policy_scope(@project.tickets).includes(:assignee, :reporter).order(updated_at: :desc).limit(10)
    @memberships = @project.project_memberships.includes(:user).order(created_at: :asc)
  end

  def new
    @project = Project.new
    authorize @project
  end

  def create
    @project = Project.new(project_params)
    authorize @project

    if @project.save
      @project.project_memberships.find_or_create_by!(user: current_user) do |membership|
        membership.role = :manager
      end

      redirect_to board_project_path(@project), notice: "Project created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project

    if @project.update(project_params)
      redirect_to project_path(@project), notice: "Project updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project
    @project.destroy
    redirect_to projects_path, notice: "Project deleted."
  end

  def board
    authorize @project, :show?

    @members = @project.members.order(:first_name, :last_name)
    @labels = policy_scope(@project.labels).order(:name)
    filtered_scope = apply_filters(policy_scope(@project.tickets).includes(:assignee, :reporter, :labels))
    @tickets_by_status = Ticket.statuses.keys.index_with { |status| filtered_scope.public_send(status).order(position: :asc, created_at: :asc).to_a }

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def settings
    authorize @project, :update?
    @memberships = @project.project_memberships.includes(:user).order(created_at: :asc)
    @labels = policy_scope(@project.labels).order(:name)
    @label = @project.labels.new(color: "#22C55E")
    authorize @label
  end

  private

  def set_project
    @project = policy_scope(Project).find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :key, :description)
  end

  def apply_filters(scope)
    scoped = scope
    scoped = scoped.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
    scoped = scoped.where(priority: params[:priority]) if params[:priority].present? && Ticket.priorities.key?(params[:priority])
    scoped = scoped.where(ticket_type: params[:ticket_type]) if params[:ticket_type].present? && Ticket.ticket_types.key?(params[:ticket_type])
    scoped = scoped.joins(:labels).where(labels: { id: params[:label_id] }) if params[:label_id].present?

    return scoped if params[:q].blank?

    sanitized = ActiveRecord::Base.sanitize_sql_like(params[:q])
    scoped.where("LOWER(tickets.title) LIKE :term OR LOWER(tickets.description) LIKE :term", term: "%#{sanitized.downcase}%")
  end
end
