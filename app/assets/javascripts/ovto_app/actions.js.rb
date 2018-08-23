require 'ovto'
require 'ovto_app/actions/dnd_actions'
require 'ovto_app/actions/project_actions'
require 'ovto_app/actions/task_actions'

class MyApp < Ovto::App
  class Actions < Ovto::Actions
    include DndActions
    include ProjectActions
    include TaskActions

    def select_main_view(state:, view:)
      return {main_view: view}
    end

    def show_task_details(state:, task:)
      return {focused_task: task}
    end

    def hide_task_details(state:)
      return {focused_task: nil}
    end
  end
end
