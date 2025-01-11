class Api::V1::TasksController < ApplicationController
  def index
    tasks = Task.all
    render json: { tasks: tasks }
  end

  def create
    task = Task.new(task_params)

    if task.save
      render json: { task: task }, status: :created
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_status
    task = Task.find(params[:id])
    if task.update(status_params)
      render json: { task: task }, status: :ok
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, :description)
  end

  def status_params
    params.permit(:status)
  end
end
