require 'ovto'

class MyApp < Ovto::App
  class Actions < Ovto::Actions
    module TaskActions
      def get_tasks(state:)
        fetch('/tasks.json?done=0').then {|json|
          actions.receive_tasks(tasks: json.map{|x| Task.from_json(x)})
        }.fail {|e|
          console.log("get_tasks", e)
        }
      end

      def receive_tasks(state:, tasks:)
        return {tasks: tasks}
      end

      def request_create_task(state:, title:, due_date:, project_id:)
        params = {
          task: {
            title: title,
            done: '0',
            due_date: due_date,
            project_id: project_id,
          }
        }
        fetch('/tasks.json', 'POST', params).then {|json|
          actions.receive_new_task(task: Task.from_json(json))
        }.fail {|e|
          console.log("request_create_task", e)
        }
      end

      def receive_new_task(state:, task:)
        return {tasks: state.tasks + [task]}
      end

      def request_update_task(state:, task:)
        params = {
          _method: "patch",
          task: task.to_h
        }
        fetch("/tasks/#{task.id}.json", 'PUT', params).then {|json|
          if json[:next_task]
            actions.receive_new_task(task: Task.from_json(json[:next_task]))
          end
        }.fail {|e|
          console.log("update_task", e)
        }
        if task.done
          return {tasks: Task.delete(state.tasks, task)}
        else
          return {tasks: Task.merge(state.tasks, task)}
        end
      end

      #
      # Task editor
      #

      def open_task_editor(state:, task:)
        return {focused_task: task, editing_task: task.dup}
      end

      def close_task_editor(state:)
        return {focused_task: nil, editing_task: nil}
      end

      def edit_task(state:, diff:)
        return {editing_task: state.editing_task.merge(diff)}
      end
    end
  end
end
