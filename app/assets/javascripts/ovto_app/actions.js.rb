require 'ovto'
require 'ovto_app/actions/dnd_actions'
require 'ovto_app/actions/project_actions'
require 'ovto_app/actions/task_actions'

class MyApp < Ovto::App
  class Actions < Ovto::Actions
    include DndActions
    include ProjectActions
    include TaskActions

    def fetch(*args)
      started_at = Time.now
      promise = Promise.new
      actions.increment_connection(started_at: started_at)
      Ovto.fetch(*args).then{|*args|
        actions.decrement_connection(started_at: started_at)
        promise.resolve(*args)
      }.fail{|e|
        promise.reject(e)
      }
      return promise
    end

    def increment_connection(state:, started_at:)
      return {n_connections: state.n_connections + 1}
    end

    def decrement_connection(state:, started_at:)
      return {n_connections: state.n_connections - 1}
    end

    def show_upcoming_tasks(state:)
      return {main_view: MainViewInfo.new(type: :upcoming_tasks)}
    end

    def show_projects(state:)
      return {main_view: MainViewInfo.new(type: :projects)}
    end

    def show_project(state:, project_id:)
      return {main_view: MainViewInfo.new(type: :project, project_id: project_id)}
    end

    def on_keydown(key:)
      case key
      when "Escape"
        actions.close_task_editor()
      else
        #console.log("key", key)
      end
      nil
    end
  end
end
