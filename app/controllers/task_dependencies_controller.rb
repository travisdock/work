class TaskDependenciesController < ApplicationController
  before_action :set_task_dependency, only: [:destroy]

  def create
    @task_dependency = TaskDependency.new(task_dependency_params)

    if @task_dependency.save
      render json: {
        status: 'success',
        message: 'Dependency created successfully'
      }
    else
      render json: {
        status: 'error',
        errors: @task_dependency.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @task_dependency.destroy
    render json: {
      status: 'success',
      message: 'Dependency removed successfully'
    }
  end

  private

  def set_task_dependency
    @task_dependency = TaskDependency.find(params[:id])
  end

  def task_dependency_params
    params.require(:task_dependency).permit(:predecessor_task_id, :successor_task_id, :dependency_type)
  end
end
