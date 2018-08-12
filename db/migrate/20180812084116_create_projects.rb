class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :title, null: false
      t.boolean :archived, null: false
      t.integer :position, null: true
      t.datetime :archived_at, null: true

      t.timestamps
    end
    add_reference :tasks, :project, null: true
  end
end
