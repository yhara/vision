require 'opal'
require 'ovto'
require 'json'
require 'set'
require 'date'

class MyApp < Ovto::App
  # Dummy date for unscheduled tasks
  DATE_UNSORTED = Date.new(2000, 1, 1)

  def self.start
    app = MyApp.new
    app.run(id: 'ovto-view')
    app.actions.get_tasks
    app.actions.get_projects
  end
end
