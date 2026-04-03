class LabelsController < ApplicationController
  before_action :set_project
  before_action :set_label, only: %i[update destroy]

  def index
    @label = @project.labels.new
    authorize @label, :index?
    @labels = policy_scope(@project.labels).order(:name)
  end

  def create
    @label = @project.labels.new(label_params)
    authorize @label

    if @label.save
      redirect_to settings_project_path(@project), notice: "Label created successfully."
    else
      redirect_to settings_project_path(@project), alert: @label.errors.full_messages.to_sentence
    end
  end

  def update
    authorize @label

    if @label.update(label_params)
      redirect_to settings_project_path(@project), notice: "Label updated successfully."
    else
      redirect_to settings_project_path(@project), alert: @label.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize @label
    @label.destroy
    redirect_to settings_project_path(@project), notice: "Label deleted."
  end

  private

  def set_project
    @project = policy_scope(Project).find(params[:project_id])
  end

  def set_label
    @label = policy_scope(@project.labels).find(params[:id])
  end

  def label_params
    params.require(:label).permit(:name, :color)
  end
end
