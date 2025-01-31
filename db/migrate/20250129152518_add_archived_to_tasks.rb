class AddArchivedToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :archived, :boolean, default: false, null: false
  end
end
