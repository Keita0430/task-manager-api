class Task < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }

  enum :status, { todo: 0, in_progress: 1, done: 2, pending: 3 }, validate: true

  def self.adjust_positions_after_move(task, new_status, new_position)
    ActiveRecord::Base.transaction do
      unless Task.statuses.keys.include?(new_status)
        raise ArgumentError, "Invalid status: #{new_status}"
      end

      # 同じステータス内で順番を入れ替える場合
      if task.status == new_status
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
      else
        # 異なるステータスに移動する場合
        # 移動元のステータスの位置を1つずつ調整
        Task.where(status: task.status).where("position > ?", task.position).each do |other_task|
          other_task.update!(position: other_task.position - 1)
        end

        # 移動先のステータスの位置を調整
        Task.where(status: new_status).where("position >= ?", new_position).each do |other_task|
          other_task.update!(position: other_task.position + 1)
        end
      end

      # 移動したタスクのステータスと位置を更新
      task.update!(status: new_status, position: new_position)
    end
  rescue => e
    Rails.logger.error("Position adjustment failed: #{e.message}")
    raise e
  end
end
