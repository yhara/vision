require 'ovto'
require 'ovto_app/components/main_content'
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
          o TaskDetails, focused_task: state.focused_task
        end
      end
    end

    # Only shown in mobile devices
    class ShowProjectsLink < Ovto::Component
      def render
        o '.ShowProjectsLink', onclick: ->{ actions.show_projects() } do
          o 'div', "Projects"
        end
      end
    end
  end
end
