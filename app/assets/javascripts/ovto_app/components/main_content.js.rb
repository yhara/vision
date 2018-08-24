require 'ovto'

class MyApp < Ovto::App
  class View < Ovto::Component
    class MainContent < Ovto::Component
      def render(state:, main_view:)
        o '.MainContent' do
          o ShowProjectsLink
          case main_view.type
          when :upcoming_tasks
            o TaskListByDueDate, tasks: state.tasks
          when :projects
            o MobileProjectList, projects: state.projects
          when :project
            o TaskListOfProject, project_id: main_view.project_id
          else
            raise "state.main_view is invalid: #{main_view}"
          end
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
          ondragenter: ->(e){ actions.drag_enter(drop_target: drop_target); e.preventDefault(); e.stopPropagation() },
          ondragover: ->(e){ actions.drag_over(); e.preventDefault(); e.stopPropagation() },
          ondragleave: ->(e){ actions.drag_leave(); e.stopPropagation() },
          ondrop: ->(e){ actions.drag_drop() },
          class: (is_hovered && 'hover')
        } do
          o 'h2', label
          o TaskList, tasks: tasks, show_due_date: (due_date == DATE_UNSORTED)
          o TaskForm, due_date: due_date
        end
      end
    end

    class TaskList < Ovto::Component
      def render(tasks:, show_due_date:)
        o '.TaskList' do
          o 'ul' do
            tasks.each do |task|
              o 'li', key: task.id do
                o TaskListItem, task: task, show_due_date: show_due_date
              end
            end
          end
        end
      end
    end

    class TaskListItem < Ovto::Component
      def render(state:, task:, show_due_date:)
        project = Project.find(state.projects, task.project_id)
        o '.TaskListItem', {
          draggable: true,
          ondragstart: ->{ actions.drag_start(task: task) },
        } do
          o CompleteTaskButton, task: task
          o TaskListItemDetails, task: task, show_due_date: show_due_date
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

      class TaskListItemDetails < Ovto::Component
        def render(state:, task:, show_due_date:)
          project = Project.find(state.projects, task.project_id)
          o '.TaskListItemDetails', onclick: ->{ actions.show_task_details(task: task) } do
            o 'span.title', task.title
            o 'span.project-title', (project && project.title)
            if show_due_date
              o 'span.due-date', task.due_date && task.due_date.strftime('%-m/%-d')
            end
          end
        end
      end
    end

    class TaskForm < Ovto::Component
      def render(due_date:, project_id: nil)
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
            actions.request_create_task(title: new_title, due_date: new_due_date, project_id: project_id)
            # Clear inputs
            `document.querySelector('#'+id_title).value = ""`
            `document.querySelector('#'+id_due_date).value = ""`
          }
        end
      end
    end

    class MobileProjectList < Ovto::Component
      def render(projects:)
        o 'ul.MobileProjectList' do
          projects.each do |project|
            o MobileProjectListItem, project: project
          end
        end
      end

      class MobileProjectListItem < Ovto::Component
        def render(state:, project:)
          n_tasks = Task.find_by_project(state.tasks, project.id).length
          o 'li.MobileProjectListItem', {
            onclick: ->{ actions.show_project(project_id: project.id) },
          } do
            o 'span.project_title', project.title
            o 'span.n_tasks', "(#{n_tasks})"
          end
        end
      end
    end

    class TaskListOfProject < Ovto::Component
      def render(state:, project_id:)
        project = Project.find(state.projects, project_id)
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
          o TaskForm, due_date: DATE_UNSORTED, project_id: project.id
        end
      end

      class ClearProjectButton < Ovto::Component
        def render
          o 'span.ClearProjectButton', onclick: ->{ actions.show_upcoming_tasks() } do
            '←'
          end
        end
      end
    end
  end
end
