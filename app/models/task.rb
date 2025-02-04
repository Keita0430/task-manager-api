class Task < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }

  enum :status, { todo: 0, in_progress: 1, done: 2, pending: 3 }, validate: true

  def self.reorder_tasks(task, new_status, new_position)
    Task.validate_status!(new_status)

    ActiveRecord::Base.transaction do
      # 同じステータス内で順番を入れ替える場合
      if task.status == new_status
        reorder_within_same_status(new_position, new_status, task)
      else
        # 異なるステータスに移動する場合
        reorder_across_different_status(new_position, new_status, task)
      end
      # 移動したタスクのステータスと位置を更新
      task.update!(status: new_status, position: new_position)
    end
  rescue => e
    Rails.logger.error("Position adjustment failed: #{e.message}")
    raise e
  end

  def self.reorder_tasks_after_removal(task)
    Task.where(status: task.status).where("position > ?", task.position).each do |other_task|
      other_task.update!(position: other_task.position - 1)
    end
  end

  def move_unarchived_task_to_end
    last_position = Task.where(status: status, archived: false).count
    update!(position: last_position)
  end

  private

  def self.validate_status!(status)
    unless Task.statuses.keys.include?(status)
      raise ArgumentError, "Invalid status: #{status}"
    end
  end

  def self.reorder_within_same_status(new_position, new_status, task)
    # タスクの位置が小さくなった場合
    if task.position > new_position
      Task.where(status: new_status).where("position >= ? AND position < ?", new_position, task.position).each do |other_task|
        other_task.update!(position: other_task.position + 1)
      end
    end

    # タスクの位置が大きくなった場合
    if task.position < new_position
      Task.where(status: new_status).where("position <= ? AND position > ?", new_position, task.position).each do |other_task|
        other_task.update!(position: other_task.position - 1)
      end
    end
  end

  def self.reorder_across_different_status(new_position, new_status, task)
    # 移動元のステータスの位置を1つずつ調整
    Task.where(status: task.status).where("position > ?", task.position).each do |other_task|
      other_task.update!(position: other_task.position - 1)
    end

    # 移動先のステータスの位置を調整
    Task.where(status: new_status).where("position >= ?", new_position).each do |other_task|
      other_task.update!(position: other_task.position + 1)
    end
  end
end
