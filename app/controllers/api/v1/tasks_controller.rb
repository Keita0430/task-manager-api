class Api::V1::TasksController < ApplicationController
  def index
    tasks = Task.all.where(archived: false)
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

  def update
    task = Task.find(params[:id])
    if task.update(task_params)
      render json: { task: task }, status: :ok
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      task = Task.find(params[:id])

      task.destroy!

      Task.reorder_tasks_after_removal(task)

      updated_tasks = Task.all
      render json: { tasks: updated_tasks }, status: :ok
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :not_found
  rescue StandardError => e
    render json: { errors: "Unexpected error: #{e.message}" }, status: :internal_server_error
  end

  def reorder
    task = Task.find(params[:task][:id])
    new_status = params[:task][:status]
    new_position = params[:task][:position]

    Task.reorder_tasks(task, new_status, new_position)

    tasks = Task.all.where(archived: false)
    render json: { tasks: tasks }, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :not_found
  rescue ArgumentError => e
    render json: { errors: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { errors: "Unexpected error: #{e.message}" }, status: :internal_server_error
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :status, :position)
  end
end
