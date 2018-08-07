require 'opal'
require 'ovto'
require 'json'
require 'set'

class MyApp < Ovto::App
  class Task < Ovto::State
    item :id
    item :title
    item :done
    item :due_date
    item :created_at
    item :updated_at
    item :url

    # Update the `task` in `tasks`
    def self.merge(tasks, task)
      tasks.map{|t| t.id == task.id ? task : t}
    end

    # Remove `task` from `tasks`
    def self.delete(tasks, task)
      tasks.reject{|t| t.id == task.id}
    end
  end

  class State < Ovto::State
    item :tasks, default: []
  end

  class Actions < Ovto::Actions
    def get_tasks(state:)
      return Ovto.fetch('/tasks.json').then {|json|
        {tasks: json.map{|x| Task.new(**x)}}
      }.fail {|e|
        console.log("get_tasks", e)
      }
    end

    def create_task(state:, title:, due_date:)
      params = {
        task: {
          title: title,
          done: '0',
          due_date: due_date,
        }
      }
      return Ovto.fetch('/tasks.json', 'POST', params).then {|json|
        {tasks: state.tasks + [Task.new(**json)]}
      }.fail {|e|
        console.log("create_task", e)
      }
    end

    def update_task(state:, task:, done:)
      params = {
        task: {
          done: (done ? '1' : '0'),
        },
        _method: "patch",
      }
      return Ovto.fetch("/tasks/#{task.id}.json", 'PUT', params).then {|json|
        updated_task = Task.new(**json)
        if updated_task.done
          {tasks: Task.delete(state.tasks, updated_task)}
        else
          {tasks: Task.merge(state.tasks, updated_task)}
        end
      }.fail {|e|
        console.log("create_task", e)
      }
    end
  end

  class View < Ovto::Component
    def render(state:)
      o 'div' do
        o 'h1', 'Vision'
        o TaskListByDueDate, tasks: state.tasks
        o TaskForm
      end
    end

    class TaskListByDueDate < Ovto::Component
      def render(tasks: tasks)
        task_groups = tasks.to_set.classify(&:due_date)
        sorted_groups = task_groups.sort_by{|due_date, tasks|
          due_date || "2001-01-01"
        }
        o '.TaskListByDueDate' do
          sorted_groups.each do |due_date, tasks|
            o 'h2', due_date || 'Unsorted'
            o TaskList, tasks: tasks
          end
        end
      end
    end

    class TaskList < Ovto::Component
      def render(tasks: tasks)
        o '.TaskList' do
          o 'ul' do
            tasks.each do |task|
              o 'li' do
                o Task, {task: task}
              end
            end
          end
        end
      end
    end

    class Task < Ovto::Component
      def render(task: task)
        o '.Task', onclick: ->{ p task } do
          o CompleteTaskButton, task: task
          o 'span.title', task.title
          o 'span.due-date', task.due_date
        end
      end
    end

    class CompleteTaskButton < Ovto::Component
      def render(task: task)
        o 'span.CompleteTaskButton' do
          o 'a', {
            href: "#",
            onclick: ->{ actions.update_task(task: task, done: true); false }
          }, "○"
        end
      end
    end

    class TaskForm < Ovto::Component
      def render
        o '.TaskForm' do
          o 'input#new-task-title', type: 'text'
          o 'input#new-task-due-date', type: 'date'
          o 'input#add-task-button', type: 'button', value: 'Add', onclick: ->{
            title = `document.querySelector('#new-task-title').value`
            due_date = `document.querySelector('#new-task-due-date').value`
            actions.create_task(title: title, due_date: due_date)
          }
        end
      end
    end
  end

  def startup
    actions.get_tasks
  end
end

MyApp.run(id: 'ovto-view') if `location.pathname == "/"`
