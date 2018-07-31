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

  class TaskForm < Ovto::Component
    def render
      o 'div' do
        o 'input', type: 'text', id: 'new_task_title'
        o 'input', type: 'button', value: 'Add', onclick: ->{
          title = `document.querySelector('#new_task_title').value`
          actions.create_task(title: title)
        }
      end
    end
  end

  class View < Ovto::Component
    def render(state:)
      o 'div' do
        o 'ul' do
          state.tasks.each do |task|
            o 'li' do
              o 'a', {href: task.url}, task.title
            end
          end
        end
        o TaskForm
      end
    end
  end

  def init
    actions.get_tasks
  end
end

MyApp.run(id: 'ovto-view') if `document.querySelector('#ovto-view')`
