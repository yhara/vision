require 'ovto'
require 'ovto_app/components/current_task_list'
require 'ovto_app/components/sidebar'
require 'ovto_app/components/task_details'

class MyApp < Ovto::App
  class View < Ovto::Component
    def render(state:)
      o '.View' do
        o '.Main' do
          o MainContent
          o Sidebar
        end
        if state.focused_task
          o TaskDetails, task: state.focused_task
        end
      end
    end

    class MainContent < Ovto::Component
      def render(state:)
        o '.MainContent' do
          o ShowProjectsLink
          case state.main_view 
          when :normal
            o CurrentTaskList
          when :projects
            o MobileProjectList, projects: state.projects
          else raise
          end
        end
      end
    end

    class ShowProjectsLink < Ovto::Component
      def render
        o '.ShowProjectsLink', onclick: ->{ actions.select_main_view(view: :projects) } do
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
          onclick: ->{
            actions.select_project(project_id: project.id)
            actions.change_view(view: :normal)
          },
        } do
          o 'span.project_title', project.title
          o 'span.n_tasks', "(#{n_tasks})"
        end
      end
    end
  end
end
