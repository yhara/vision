require 'opal'
require 'ovto'
require 'json'
require 'set'
require 'date'

# Patch to fix Date#== for Opal < 0.11
class Date
  def ==(other)
    return false unless Date === other
    %x{
      var a = #@date, b = other.date;
      return (a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate());
    }
  end
  alias eql? ==
end

class MyApp < Ovto::App
  # Dummy date for unscheduled tasks
  DATE_UNSORTED = Date.new(2000, 1, 1)

  def startup
    actions.get_tasks
    actions.get_projects
  end
end
