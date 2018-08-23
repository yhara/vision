require 'ovto'
require 'ovto_app/components/current_task_list'
require 'ovto_app/components/sidebar'
require 'ovto_app/components/task_details'

class MyApp < Ovto::App
  class View < Ovto::Component
    def render(state:)
      o '.View' do
        o '.Main' do
          o MainContent, main_view: state.main_view
          o Sidebar
        end
        if state.focused_task
          o TaskDetails, task: state.focused_task
        end
      end
    end

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

    class ShowProjectsLink < Ovto::Component
      def render
        o '.ShowProjectsLink', onclick: ->{ actions.show_projects() } do
          o 'div', "Projects"
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
end
