require 'opal'
require 'ovto'
require 'json'

class MyApp < Ovto::App
  class Task < Ovto::State
    item :id
    item :title
    item :done
    item :due_date
    item :created_at
    item :updated_at
    item :url
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

    def create_task(state:, title:)
      params = {
        task: {
          title: title,
          done: '0',
          due_date: '2018-07-30'
        }
      }
      return Ovto.fetch('/tasks.json', params).then {|json|
        {tasks: state.tasks + [Task.new(**json)]}
      }.fail {|e|
        console.log("create_task", e)
      }
    end
  end

  class View < Ovto::Component
    def render(state:)
      o 'div' do
        o 'h1', 'Vision'
        o TaskList, tasks: state.tasks
        o TaskForm
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
        o '.Task' do
          o 'div', onclick: ->{ p task } do
            o CompleteTaskButton, task: task
            o 'span', task.title
          end
        end
      end
    end

    class CompleteTaskButton < Ovto::Component
      def render(task: task)
        o 'span.CompleteTaskButton' do
          o 'a', {
            href: "#",
            onclick: ->{ actions.complete_task(task: task)}
          }, "○"
        end
      end
    end

    class TaskForm < Ovto::Component
      def render
        o '.TaskForm' do
          o 'input#new-task-title', type: 'text'
          o 'input#add-task-button', type: 'button', value: 'Add', onclick: ->{
            title = `document.querySelector('#new-task-title').value`
            actions.create_task(title: title)
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
