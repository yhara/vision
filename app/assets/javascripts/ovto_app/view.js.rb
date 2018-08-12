require 'ovto'

class MyApp < Ovto::App
  class View < Ovto::Component
    def render(state:)
      o '.Main' do
        o TaskListByDueDate, tasks: state.tasks
        if state.focused_task
          o TaskDetails, task: state.focused_task
        end
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
          onclick: ->{ actions.show_task_details(task: task) },
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

    class TaskDetails < Ovto::Component
      def render(task:)
        id_title = "TaskDetails-title"
        id_due_date = "TaskDetails-due-date" 
        o '.TaskDetails' do
          o 'div' do
            o 'label', {for: id_title}, 'Title:'
            o 'input', id: id_title, type: 'text', value: task.title
          end
          o 'div' do
            o 'label', {for: id_due_date}, 'Due date:'
            o 'input', id: id_due_date, type: 'date', value: task.due_date
          end
          o 'div' do
            o 'input.save-button', type: 'button', value: 'Save', onclick: ->{
              actions.request_update_task(task: task, updates: {
                title: `document.querySelector('#'+id_title).value`,
                due_date: `document.querySelector('#'+id_due_date).value`,
              })
              actions.hide_task_details()
            }
            o 'a', {
              href: '#', onclick: ->(e){
                e.preventDefault()
                actions.hide_task_details()
              }
            }, 'Close'
          end
        end
      end
    end
  end
end
