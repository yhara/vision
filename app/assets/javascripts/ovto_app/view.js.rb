require 'ovto'

class MyApp < Ovto::App
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
end
