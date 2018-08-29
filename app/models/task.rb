class Task < ApplicationRecord
  belongs_to :project, optional: true
  has_one :next_task, class_name: 'Task', foreign_key: :next_task_id

  enum interval_type: {
    every_n_days: 0,
    n_days_after: 1,
    day_of_week:  2,
    day_of_month: 3,
    day_of_year:  4,
  }

  validates :title, presence: true
  validates :project, presence: true, if: ->{ project_id != nil }
  validates :interval_value, presence: true, if: ->{ interval_type != nil }
  validates :interval_value, numericality: { greater_than_or_equal_to: 1 }, if: ->{ interval_type == "n_days" }
  validates :interval_value, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }, if: ->{ interval_type == "day_of_week" }
  validates :interval_value, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 31 }, if: ->{ interval_type == "day_of_month" }
  validates :interval_value, numericality: { greater_than_or_equal_to: 101, less_than_or_equal_to: 1231 }, if: ->{ interval_type == "day_of_year" }

  before_update :create_next_task

  scope :done, ->{ where(done: true) }
  scope :undone, ->{ where(done: false) }

  private

  # Create next task if interval_type is set
  def create_next_task
    return if !self.done || self.interval_type.nil?
    next_task = Task.create!(title: self.title,
                                  done: false,
                                  due_date: next_due_date(Date.today),
                                  project_id: self.project_id,
                                  interval_type: self.interval_type,
                                  interval_value: self.interval_value)
    self.next_task = next_task
  end

  def next_due_date(today)
    case interval_type
    when "every_n_days"
      return (self.due_date || today) + interval_value
    when "n_days_after"
      return today + interval_value
    when "day_of_week"
      dw = %i(sunday monday tuesday wednesday thursday friday saturday)[interval_value]
      return today.next_occurring(dw)
    when "day_of_month"
      the_day = Date.new(today.year, today.month, interval_value)
      if the_day > today
        return the_day
      else
        return the_day.next_month
      end
    when "day_of_year"
      the_day = Date.new(today.year, interval_value / 100, interval_value % 100)
      if the_day > today
        return the_day
      else
        return the_day.next_year
      end
    else
      raise "invalid interval_type: #{interval_type.inspect}"
    end
  end
end
