class TaskDependenciesController < ApplicationController
  before_action :set_task_dependency, only: [ :destroy ]
  before_action :authorize_task_dependency_creation, only: [ :create ]
  before_action :authorize_task_dependency_deletion, only: [ :destroy ]

  def create
    @task_dependency = TaskDependency.new(task_dependency_params)

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
  end

  def destroy
    @task_dependency.destroy
    render json: {
      status: "success",
      message: "Dependency removed successfully"
    }
  end

  private

  def set_task_dependency
    @task_dependency = TaskDependency.find(params[:id])
  end

  def authorize_task_dependency_creation
    predecessor = Task.find_by(id: task_dependency_params[:predecessor_task_id])
    successor = Task.find_by(id: task_dependency_params[:successor_task_id])

    unless predecessor && successor &&
           task_owned_by_user?(predecessor) &&
           task_owned_by_user?(successor)
      render json: {
        status: "error",
        message: "Unauthorized: You can only create dependencies between your own tasks"
      }, status: :forbidden
    end
  end

  def authorize_task_dependency_deletion
    predecessor = @task_dependency.predecessor_task
    successor = @task_dependency.successor_task

    unless task_owned_by_user?(predecessor) && task_owned_by_user?(successor)
      render json: {
        status: "error",
        message: "Unauthorized: You can only delete dependencies for your own tasks"
      }, status: :forbidden
    end
  end

  def task_owned_by_user?(task)
    task&.user_id == current_user.id
  end

  def task_dependency_params
    params.require(:task_dependency).permit(:predecessor_task_id, :successor_task_id, :dependency_type)
  end
end
