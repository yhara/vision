class AddNextTaskIdToTasks < ActiveRecord::Migration[5.2]
  def change
    add_reference :tasks, :next_task, index: false
  end
end
