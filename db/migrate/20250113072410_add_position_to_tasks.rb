class AddPositionToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :position, :integer, default: 0, null: false
  end
end
