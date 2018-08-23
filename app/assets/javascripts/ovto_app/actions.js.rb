require 'ovto'
require 'ovto_app/actions/dnd_actions'
require 'ovto_app/actions/project_actions'
require 'ovto_app/actions/task_actions'

class MyApp < Ovto::App
  class Actions < Ovto::Actions
    include DndActions
    include ProjectActions
    include TaskActions

    def show_upcoming_tasks(state:)
      return {main_view: MainViewInfo.new(type: :upcoming_tasks)}
    end

    def show_projects(state:)
      return {main_view: MainViewInfo.new(type: :projects)}
    end

    def show_project(state:, project_id:)
      return {main_view: MainViewInfo.new(type: :project, project_id: project_id)}
    end

    def show_task_details(state:, task:)
      return {focused_task: task}
    end

    def hide_task_details(state:)
      return {focused_task: nil}
    end
  end
end
