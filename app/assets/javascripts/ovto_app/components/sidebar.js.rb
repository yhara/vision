require 'ovto'

class MyApp < Ovto::App
  class View < Ovto::Component
    class Sidebar < Ovto::Component
      def render(state:)
        o '.Sidebar' do
          o 'h2', 'Projects'
          o ProjectList, projects: state.projects
        end
      end
    end

    class ProjectList < Ovto::Component
      def render(projects:)
        o 'ul.ProjectList' do
          projects.each do |project|
            o ProjectListItem, project: project
          end
        end
      end
    end

    class ProjectListItem < Ovto::Component
      def render(state:, project:)
        is_hovered = state.drag_info.drop_target.type == "project" &&
                     state.drag_info.drop_target.key == project.id
        drop_target = DropTarget.new(type: "project", key: project.id)
        o 'li.ProjectListItem', {
          ondragenter: ->{ actions.drag_enter(drop_target: drop_target) },
          ondragover: ->(e){ actions.drag_over(); e.preventDefault() },
          ondragleave: ->{ actions.drag_leave() },
          ondrop: ->(e){ actions.drag_drop() },
          class: (is_hovered && 'hover')
        }, project.title
      end
    end
  end
end
