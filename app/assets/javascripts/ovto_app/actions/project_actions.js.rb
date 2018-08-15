require 'ovto'

class MyApp < Ovto::App
  class Actions < Ovto::Actions
    module ProjectActions
      def get_projects(state:)
        Ovto.fetch('/projects.json').then {|json|
          actions.receive_projects(projects: json.map{|x| Project.from_json(x)})
        }.fail {|e|
          console.log("get_projects", e)
        }
      end

      def receive_projects(state:, projects:)
        return {projects: projects}
      end

      def select_project(state:, project_id:)
        return {selected_project_id: project_id}
      end
    end
  end
end
