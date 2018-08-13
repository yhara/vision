require 'ovto'
require 'ovto_app/components/sidebar'

class MyApp < Ovto::App
  class View < Ovto::Component
    def render(state:)
      o '.View' do
        o '.Main' do
          o TaskListByDueDate, tasks: state.tasks
          o Sidebar
        end
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
        is_hovered = state.drag_info.drop_target.type == "due_date" &&
                     state.drag_info.drop_target.key == due_date
        drop_target = DropTarget.new(type: "due_date", key: due_date)
        o '.TasksOfADay', {
          ondragenter: ->{ actions.drag_enter(drop_target: drop_target) },
          ondragover: ->(e){ actions.drag_over(); e.preventDefault() },
          ondragleave: ->{ actions.drag_leave() },
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
      def render(state:, task:)
        project = Project.find(state.projects, task.project_id)
        o '.TaskListItem', {
          draggable: true,
          ondragstart: ->{ actions.drag_start(task: task) },
        } do
          o CompleteTaskButton, task: task
          o TaskListItemDetails, task: task
        end
      end
    end

    class TaskListItemDetails < Ovto::Component
      def render(state:, task:)
        project = Project.find(state.projects, task.project_id)
        o '.TaskListItemDetails', onclick: ->{ actions.show_task_details(task: task) } do
          o 'span.title', task.title
          o 'span.project-title', (project && project.title)
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
        unsorted = (due_date == DATE_UNSORTED)
        o '.TaskForm' do
          id_title = "new-task-#{due_date}-title"
          id_due_date = "new-task-#{due_date}-due-date" 
          o 'input.new-task-title', id: id_title, type: 'text'
          if unsorted
            o 'input.new-task-due-date', id: id_due_date, type: 'date'
          else
            o 'input.new-task-due-date', id: id_due_date, type: 'hidden', value: due_date
          end
          o 'input.add-task-button', type: 'button', value: 'Add', onclick: ->{
            new_title = `document.querySelector('#'+id_title).value`
            new_due_date = `document.querySelector('#'+id_due_date).value`
            actions.request_create_task(title: new_title, due_date: new_due_date)
          }
        end
      end
    end

    class TaskDetails < Ovto::Component
      def render(state:, task:)
        id_title = "TaskDetails-title"
        id_due_date = "TaskDetails-due-date" 
        id_project = "TaskDetails-project"
        o '.TaskDetailsContainer' do
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
              o 'label', {for: id_project}, 'Project:'
              o 'select', id: id_project do
                o 'option', {value: ""}, "---"
                state.projects.each do |project|
                  o 'option', {
                    value: project.id,
                    selected: task.project_id == project.id
                  }, project.title 
                end
              end
            end
            o 'div' do
              o 'input.save-button', type: 'button', value: 'Save', onclick: ->{
                actions.request_update_task(task: task, updates: {
                  title: `document.querySelector('#'+id_title).value`,
                  due_date: `document.querySelector('#'+id_due_date).value`,
                  project_id: `document.querySelector('#'+id_project).value`.to_i,
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
end
