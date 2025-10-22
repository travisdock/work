class TaskDependenciesController < ApplicationController
  before_action :set_task_dependency, only: [ :destroy ]

  def create
    predecessor_task = find_task_for_current_user(task_dependency_params[:predecessor_task_id])
    successor_task = find_task_for_current_user(task_dependency_params[:successor_task_id])

    @task_dependency = TaskDependency.new(
      predecessor_task: predecessor_task,
      successor_task: successor_task,
      dependency_type: task_dependency_params[:dependency_type]
    )

    if @task_dependency.save
      render json: {
        status: "success",
        message: "Dependency created successfully"
      }
    else
      render json: {
        status: "error",
        errors: @task_dependency.errors.full_messages
      }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    handle_unauthorized_dependency
  end

  def destroy
    @task_dependency.destroy
    render json: {
      status: "success",
      message: "Dependency removed successfully"
    }
  rescue ActiveRecord::RecordNotFound
    handle_unauthorized_dependency
  end

  private

  def set_task_dependency
    @task_dependency = TaskDependency
      .joins(:successor_task)
      .merge(Current.user.tasks)
      .find(params[:id])
  end

  def task_dependency_params
    params.require(:task_dependency).permit(:predecessor_task_id, :successor_task_id, :dependency_type)
  end

  def find_task_for_current_user(task_id)
    Current.user.tasks.find(task_id)
  end

  def handle_unauthorized_dependency
    render json: {
      status: "error",
      errors: [ "You are not authorized to modify these tasks" ]
    }, status: :forbidden
  end
end
