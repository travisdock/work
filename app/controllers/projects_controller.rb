class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show, :edit, :update, :destroy, :archive ]

  def index
    @active_projects = Current.user.projects.not_completed.by_priority
    @archived_projects = Current.user.projects.archived.by_completed_at
  end

  def show
    @tasks = @project.tasks.root_tasks.includes(:subtasks, :predecessors, :successors).by_position
  end

  def new
    @project = Current.user.projects.build
  end

  def create
    @project = Current.user.projects.build(project_params)

    if @project.save
      redirect_to @project, notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: "Project was successfully deleted."
  end

  def archive
    @project.update(status: :completed)
    redirect_to @project, notice: "Project was archived."
  end

  private

  def set_project
    @project = Current.user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(
      :name, :description, :start_date, :due_date, :status,
      :priority_number, :next_action, priority_tags: []
    )
  end
end
