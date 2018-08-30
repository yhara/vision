class AddIntervalToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :interval_type, :integer, null: true
    add_column :tasks, :interval_value, :integer, null: true
  end
end
