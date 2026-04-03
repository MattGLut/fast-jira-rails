class ProjectMembershipsController < ApplicationController
  before_action :set_project
  skip_after_action :verify_policy_scoped, only: :index

  def index
    authorize @project, :update?
    @memberships = @project.project_memberships.includes(:user).order(created_at: :asc)
    @available_users = User.where.not(id: @memberships.select(:user_id)).order(:first_name, :last_name)
  end

  def create
    authorize @project, :update?
    membership = @project.project_memberships.new(membership_params)

    if membership.save
      redirect_to settings_project_path(@project), notice: "Member added successfully."
    else
      redirect_to settings_project_path(@project), alert: membership.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize @project, :update?
    membership = @project.project_memberships.find(params[:id])
    membership.destroy
    redirect_to settings_project_path(@project), notice: "Member removed."
  end

  private

  def set_project
    @project = policy_scope(Project).find(params[:project_id])
  end

  def membership_params
    params.require(:project_membership).permit(:user_id, :role)
  end
end
