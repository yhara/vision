require 'ovto'

class MyApp < Ovto::App
  class Task < Ovto::State
    item :id
    item :title
    item :done
    item :due_date
    item :project_id
    item :interval_type
    item :interval_value
    item :created_at
    item :updated_at
    item :url

    # Convert the string returned by the server into Date class
    def due_date
      if @values[:due_date] != nil && @values[:due_date] != ""
        @date_due_date ||= Date.parse(@values[:due_date])
      end
    end

    def self.from_json(json)
      Task.new(**json)
    end

    # Update the `task` in `tasks`
    def self.merge(tasks, task)
      tasks.map{|t| t.id == task.id ? task : t}
    end

    # Remove `task` from `tasks`
    def self.delete(tasks, task)
      tasks.reject{|t| t.id == task.id}
    end

    def self.unsorted_or_outdated(tasks)
      tasks.select{|t| t.project_id == nil}
           .select{|t| t.due_date.nil? || t.due_date < Date.today}
    end

    def self.find_by_project(tasks, project_id)
      tasks.select{|t| t.project_id == project_id}
    end
  end

  class Project < Ovto::State
    item :id
    item :title
    item :position
    item :archived
    item :archived_at
    item :created_at
    item :updated_at
    item :url

    def self.from_json(json)
      Project.new(**json)
    end

    def self.find(projects, id)
      projects.find{|x| x.id == id}
    end
  end

  class DropTarget < Ovto::State
    item :type, default: nil  # "due_date" || "project"
    item :key, default: nil   # the due date or project_id
  end

  class DragInfo < Ovto::State
    item :task_id, default: nil
    item :drop_target, default: DropTarget.new
    item :dragover_occurred, default: false
  end

  class MainViewInfo < Ovto::State
    item :type  # :upcoming_tasks, :projects, :project
    item :project_id, default: nil
  end

  class State < Ovto::State
    item :tasks, default: []
    item :projects, default: []
    item :focused_task, default: nil
    item :editing_task, default: nil
    item :drag_info, default: DragInfo.new
    item :main_view, default: MainViewInfo.new(type: :upcoming_tasks)
  end
end
