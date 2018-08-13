require 'ovto'

class MyApp < Ovto::App
  class View < Ovto::Component
    class Sidebar < Ovto::Component
      def render(state:)
        o '.Sidebar' do
          o 'h2', 'Projects'
          o 'ul' do
            state.projects.each do |project|
              o 'li', project.title
            end
          end
        end
      end
    end
  end
end
