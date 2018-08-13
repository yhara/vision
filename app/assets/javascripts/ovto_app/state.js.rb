require 'ovto'

class MyApp < Ovto::App
  class Task < Ovto::State
    item :id
    item :title
    item :done
    item :due_date
    item :project_id
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
      tasks.select{|t| t.due_date.nil? || t.due_date < Date.today}
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

  class DragInfo < Ovto::State
    item :task_id, default: nil
    item :target_date, default: nil
    item :dragover_occurred, default: false
  end

  class State < Ovto::State
    item :tasks, default: []
    item :projects, default: []
    item :focused_task, default: nil
    item :drag_info, default: DragInfo.new
  end
end
