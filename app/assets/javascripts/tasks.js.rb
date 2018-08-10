require 'opal'
require 'ovto'
require 'json'
require 'set'
require 'date'

# Patch to fix Date#== for Opal < 0.11
class Date
  def ==(other)
    return false unless Date === other
    %x{
      var a = #@date, b = other.date;
      return (a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate());
    }
  end
  alias eql? ==
end

class MyApp < Ovto::App
  # Dummy date for unscheduled tasks
  DATE_UNSORTED = Date.new(2000, 1, 1)

  class Task < Ovto::State
    item :id
    item :title
    item :done
    item :due_date
    item :created_at
    item :updated_at
    item :url

    # Convert the string returned by the server into Date class
    def due_date
      if @values[:due_date]
        @date_due_date ||= Date.parse(@values[:due_date])
      end
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

  class DragInfo < Ovto::State
    item :task_id, default: nil
    item :target_date, default: nil
    item :dragover_occurred, default: false
  end

  class State < Ovto::State
    item :tasks, default: []
    item :drag_info, default: DragInfo.new
  end

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
  end

  class View < Ovto::Component
    def render(state:)
      o '.Main' do
        o 'h1', 'Vision'
        o TaskListByDueDate, tasks: state.tasks
      end
    end

    class TaskListByDueDate < Ovto::Component
      def render(tasks:)
        task_groups = [
          { label: 'Unsorted/Outdated',
            due_date: DATE_UNSORTED,
            tasks: Task.unsorted_or_outdated(tasks) }
        ]
        7.times.each do |i|
          date = Date.today + i
          prefix = case i
                   when 0 then 'Today '
                   when 1 then 'Tomorrow '
                   else ''
                   end
          label = prefix + date.strftime('%a %-m/%-d')
          task_groups << {
            label: label,
            due_date: date,
            tasks: tasks.select{|t| t.due_date == date}
          }
        end
        o '.TaskListByDueDate' do
          task_groups.each do |group|
            o TasksOfADay, **group
          end
        end
      end
    end

    class TasksOfADay < Ovto::Component
      def render(state:, label:, due_date:, tasks:)
        is_hovered = state.drag_info.target_date == due_date
        o '.TasksOfADay', {
          ondragenter: ->{ actions.drag_enter(target_date: due_date) },
          ondragover: ->(e){ actions.drag_over(target_date: due_date); e.preventDefault() },
          ondragleave: ->{ actions.drag_leave(target_date: due_date) },
          ondrop: ->(e){ actions.drag_drop() },
          class: (is_hovered && 'hover')
        } do
          o 'h2', label
          o TaskList, tasks: tasks
          o TaskForm, due_date: due_date
        end
      end
    end

    class TaskList < Ovto::Component
      def render(tasks:)
        o '.TaskList' do
          o 'ul' do
            tasks.each do |task|
              o 'li', key: task.id do
                o TaskListItem, {task: task}
              end
            end
          end
        end
      end
    end

    class TaskListItem < Ovto::Component
      def render(task:)
        o '.TaskListItem', {
          draggable: true,
          ondragstart: ->{ actions.drag_start(task: task) },
        } do
          o CompleteTaskButton, task: task
          o 'span.title', task.title
          o 'span.due-date', task.due_date.to_s
        end
      end
    end

    class CompleteTaskButton < Ovto::Component
      def render(task:)
        o 'span.CompleteTaskButton' do
          o 'a', {
            href: "#",
            onclick: ->{ actions.request_update_task(task: task, updates: {done: true}); false }
          }, "○"
        end
      end
    end

    class TaskForm < Ovto::Component
      def render(due_date:)
        o '.TaskForm' do
          id_title = "new-task-#{due_date}-title"
          id_due_date = "new-task-#{due_date}-due-date" 
          o 'input.new-task-title', id: id_title, type: 'text'
          o 'input.new-task-due-date', id: id_due_date, type: 'date', value: (due_date if due_date != DATE_UNSORTED)
          o 'input.add-task-button', type: 'button', value: 'Add', onclick: ->{
            title = `document.querySelector('#'+id_title).value`
            due_date = `document.querySelector('#'+id_due_date).value`
            actions.request_create_task(title: title, due_date: due_date)
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
