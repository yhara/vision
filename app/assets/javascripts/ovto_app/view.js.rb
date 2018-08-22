require 'ovto'
require 'ovto_app/components/current_task_list'
require 'ovto_app/components/sidebar'
require 'ovto_app/components/task_details'

class MyApp < Ovto::App
  class View < Ovto::Component
    def render(state:)
      o '.View' do
        o '.Main' do
          o CurrentTaskList
          o Sidebar
        end
        if state.focused_task
          o TaskDetails, task: state.focused_task
        end
      end
    end
  end
end
