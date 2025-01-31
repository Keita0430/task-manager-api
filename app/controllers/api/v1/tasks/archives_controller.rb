class Api::V1::Tasks::ArchivesController < ApplicationController
  def update
    begin
      task = Task.find(params[:task_id])

      if task.update(archived: true)
        Task.reorder_tasks_after_removal(task)

        tasks = Task.all.where(archived: false)
        render json: tasks, status: :ok
      else
        render json: { error: task.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :not_found
    end
  end
end
