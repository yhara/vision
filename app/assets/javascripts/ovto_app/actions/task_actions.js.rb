require 'ovto'

class MyApp < Ovto::App
  class Actions < Ovto::Actions
    module TaskActions
      def get_tasks(state:)
        Ovto.fetch('/tasks.json').then {|json|
          actions.receive_tasks(tasks: json.map{|x| Task.from_json(x)})
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
        Ovto.fetch('/tasks.json', 'POST', params).then {|json|
          actions.receive_created_task(task: Task.from_json(json))
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
        if updates.key?(:title)
          params[:task][:title] = updates[:title]
          updated_task = updated_task.merge(title: updates[:title])
        end
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
    end
  end
end
