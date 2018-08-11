require 'ovto'

class MyApp < Ovto::App
  class Actions < Ovto::Actions
    def get_tasks(state:)
      return Ovto.fetch('/tasks.json').then {|json|
        actions.receive_tasks(tasks: json.map{|x| Task.new(**x)})
      }.fail {|e|
        console.log("get_tasks", e)
      }
    end

    def receive_tasks(state:, tasks:)
      return {tasks: tasks}
    end

    def request_create_task(state:, title:, due_date:)
      params = {
        task: {
          title: title,
          done: '0',
          due_date: due_date,
        }
      }
      return Ovto.fetch('/tasks.json', 'POST', params).then {|json|
        actions.receive_created_task(task: Task.new(**json))
      }.fail {|e|
        console.log("request_create_task", e)
      }
    end

    def receive_created_task(state:, task:)
      return {tasks: state.tasks + [task]}
    end

    def request_update_task(state:, task:, updates:)
      params = {
        _method: "patch",
        task: {}
      }
      updated_task = task.merge({})
      if updates.key?(:done)
        params[:task][:done] = (updates[:done] ? '1' : '0')
        updated_task = updated_task.merge(done: updates[:done])
      end
      if updates.key?(:due_date)
        params[:task][:due_date] = updates[:due_date].to_s
        updated_task = updated_task.merge(due_date: updates[:due_date])
      end
      Ovto.fetch("/tasks/#{task.id}.json", 'PUT', params).then {|json|
        # OK.
      }.fail {|e|
        console.log("update_task", e)
      }
      if updated_task.done
        return {tasks: Task.delete(state.tasks, updated_task)}
      else
        return {tasks: Task.merge(state.tasks, updated_task)}
      end
    end

    def drag_start(state:, task:)
      return {drag_info: state.drag_info.merge(task_id: task.id)}
    end

    def drag_enter(state:, target_date:)
      return {drag_info: state.drag_info.merge(target_date: target_date, dragover_occurred: false)}
    end

    def drag_over(state:, target_date:)
      return {drag_info: state.drag_info.merge(dragover_occurred: true)}
    end

    def drag_leave(state:, target_date:)
      if state.drag_info.dragover_occurred
        return {drag_info: state.drag_info.merge(target_date: nil, dragover_occurred: false)}
      end
    end

    def drag_drop(state:)
      task = state.tasks.find{|t| t.id == state.drag_info.task_id}
      date = state.drag_info.target_date 
      updated_task = task.dup
      if date && date != task.due_date
        new_date = (date == DATE_UNSORTED ? nil : date)
        updated_task = task.merge(due_date: new_date)
        actions.request_update_task(task: task, updates: {due_date: new_date})
      end
      return {
        drag_info: state.drag_info.merge(task_id: nil, target_date: nil, dragover_occurred: false),
        tasks: Task.merge(state.tasks, updated_task)
      }
    end

    def show_task_details(state:, task:)
      return {focused_task: task}
    end

    def hide_task_details(state:)
      return {focused_task: nil}
    end
  end
end
