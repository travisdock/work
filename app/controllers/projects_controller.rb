class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :archive]

  def index
    @projects = Project.includes(:tasks).by_priority
  end

  def show
    @tasks = @project.tasks.root_tasks.includes(:subtasks, :predecessors, :successors).by_position
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully deleted.'
  end

  def archive
    @project.update(status: :completed)
    redirect_to @project, notice: 'Project was archived.'
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(
      :name, :description, :start_date, :due_date, :status,
      :priority_number, :next_action, priority_tags: []
    )
  end
end
