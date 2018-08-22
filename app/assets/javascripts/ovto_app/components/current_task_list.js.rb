require 'ovto'

class MyApp < Ovto::App
  class View < Ovto::Component
    class CurrentTaskList < Ovto::Component
      def render(state:)
        o '.CurrentTaskList' do
          if state.selected_project_id 
            o TaskListOfProject
          else
            o TaskListByDueDate, tasks: state.tasks
          end
        end
      end
    end

    class TaskListOfProject < Ovto::Component
      def render(state:)
        project = Project.find(state.projects, state.selected_project_id)
        tasks = Task.find_by_project(state.tasks, project.id)
        o '.TaskListOfProject' do
          o 'h2' do
            o ClearProjectButton
            o 'text', project.title
          end
          if tasks.any?
            o TaskList, tasks: tasks
          else
            o 'p', '(empty)'
          end
        end
      end
    end

    class ClearProjectButton < Ovto::Component
      def render
        o 'span.ClearProjectButton', onclick: ->{ actions.select_project(project_id: nil) } do
          '←'
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
            `document.querySelector('#'+id_title).value = ""`
          }
        end
      end
    end
  end
end
