require 'opal'
require 'ovto'
require 'json'
require 'set'
require 'date'

class MyApp < Ovto::App
  # Dummy date for unscheduled tasks
  DATE_UNSORTED = Date.new(2000, 1, 1)

  def setup
    actions.get_tasks
    actions.get_projects
  end
end
