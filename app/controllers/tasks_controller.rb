class TasksController < ApplicationController
  before_action :set_project, except: [ :index, :complete ]
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :complete ]

  def index
    @tasks = Current.user.tasks.includes(:project, :predecessors, :successors).incomplete.by_position
  end

  def show
    @subtasks = @task.subtasks.includes(:predecessors, :successors).by_position
  end

  def new
    @task = @project.tasks.build
    @potential_parents = @project.tasks.all
    @potential_dependencies = @project.tasks.all
  end

  def create
    @task = @project.tasks.build(task_params)

    if @task.save
      redirect_to [ @project, @task ], notice: "Task was successfully created."
    else
      @potential_parents = @project.tasks.where.not(id: @task.id)
      @potential_dependencies = @project.tasks.where.not(id: @task.id)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @potential_parents = @project.tasks.where.not(id: @task.id)
    @potential_dependencies = @project.tasks.where.not(id: @task.id)
  end

  def update
    if @task.update(task_params)
      redirect_to [ @project, @task ], notice: "Task was successfully updated."
    else
      @potential_parents = @project.tasks.where.not(id: @task.id)
      @potential_dependencies = @project.tasks.where.not(id: @task.id)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to @project, notice: "Task was successfully deleted."
  end

  def complete
    new_status = @task.done? ? :todo : :done
    @task.update(status: new_status)

    if request.xhr?
      render json: { status: new_status, task_id: @task.id }
    else
      message = new_status == "done" ? "Task completed!" : "Task marked incomplete."
      redirect_back(fallback_location: @task.project, notice: message)
    end
  end

  private

  def set_project
    @project = Current.user.projects.find(params[:project_id])
  end

  def set_task
    if params[:project_id] && @project
      @task = @project.tasks.find(params[:id])
    else
      @task = Current.user.tasks.find(params[:id])
      @project = @task.project
    end
  end

  def task_params
    params.require(:task).permit(
      :title, :description, :parent_task_id, :start_date, :due_date,
      :status, :priority_number, :effort_estimate, :next_action,
      :position, priority_tags: []
    )
  end
end
