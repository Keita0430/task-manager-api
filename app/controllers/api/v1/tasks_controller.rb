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

  def destroy
    task = Task.find(params[:id])
    task.destroy
    head :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :not_found
  rescue StandardError => e
    render json: { errors: "Unexpected error: #{e.message}" }, status: :internal_server_error
  end

  def update_status_and_position
    task = Task.find(params[:id])
    new_status = params[:task][:status]
    new_position = params[:task][:position]

    Task.adjust_positions_after_move(task, new_status, new_position)

    render json: { task: task }, status: :ok
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
