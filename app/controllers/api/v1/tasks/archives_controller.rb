class Api::V1::Tasks::ArchivesController < ApplicationController
  before_action :set_task, only: [:update]

  def index
    archived_tasks = Task.all.where(archived: true)
    render json: { tasks: archived_tasks }
  end

  def update
    ActiveRecord::Base.transaction do
      if is_archived
        @task.update!(archived: true)
        Task.reorder_tasks_after_removal(@task)
      else
        @task.update!(archived: false)
        @task.move_unarchived_task_to_end
      end
      tasks = Task.all.where(archived: !is_archived)
      render json: { tasks: tasks }, status: :ok
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { errors: "Unexpected error: #{e.message}" }, status: :internal_server_error
  end

  private

  def is_archived
    ActiveModel::Type::Boolean.new.cast(params[:task][:archived])
  end

  def set_task
    @task = Task.find(params[:task_id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :not_found
  end
end
