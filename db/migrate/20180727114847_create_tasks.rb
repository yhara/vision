class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.boolean :done, null: false
      t.date :due_date, null: true

      t.timestamps
    end
  end
end
