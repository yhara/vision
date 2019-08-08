class RemoveArchivedFromProjects < ActiveRecord::Migration[5.2]
  def change
    remove_column :projects, :archived, :boolean, null: false
  end
end
