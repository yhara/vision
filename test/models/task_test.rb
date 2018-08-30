require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  context '#next_task' do
    should 'return the next task (if any)' do
      task = FactoryBot.create(:task,
                               project: projects(:one),
                               interval_type: :n_days_after, 
                               interval_value: 1)
      travel_to("2001-01-02")
      task.update!(done: true)
      next_task = task.reload.next_task
      assert_equal task.title, next_task.title
      assert_equal false, next_task.done
      assert_equal Date.new(2001, 1, 3), next_task.due_date
      assert_equal task.project_id, next_task.project_id
      assert_equal task.interval_type, next_task.interval_type
      assert_equal task.interval_value, next_task.interval_value
    end
  end

  context 'interval' do
    should 'every 7 days' do
      task = FactoryBot.create(:task,
                               interval_type: :every_n_days, 
                               interval_value: 7,
                               due_date: "2001-01-01")
      travel_to("2001-01-02")
      task.update!(done: true)
      assert_equal Date.new(2001, 1, 8), Task.last.due_date
    end

    should '7 days after completion' do
      task = FactoryBot.create(:task,
                               interval_type: :n_days_after, 
                               interval_value: 7,
                               due_date: "2001-01-01")
      travel_to("2001-01-02")
      task.update!(done: true)
      assert_equal Date.new(2001, 1, 9), Task.last.due_date
    end

    should 'every sunday' do
      task = FactoryBot.create(:task,
                               interval_type: :day_of_week, 
                               interval_value: 0)
      travel_to("2001-01-01")  # Monday
      task.update!(done: true)
      assert_equal Date.new(2001, 1, 7), Task.last.due_date
    end

    should 'every 10th' do
      task = FactoryBot.create(:task,
                               interval_type: :day_of_month, 
                               interval_value: 10)
      travel_to("2001-01-01")  # Monday
      task.update!(done: true)
      assert_equal Date.new(2001, 1, 10), Task.last.due_date
    end

    should 'every 1st' do
      task = FactoryBot.create(:task,
                               interval_type: :day_of_month, 
                               interval_value: 1)
      travel_to("2001-01-01")  # Monday
      task.update!(done: true)
      assert_equal Date.new(2001, 2, 1), Task.last.due_date
    end

    should 'every May 21st' do
      task = FactoryBot.create(:task,
                               interval_type: :day_of_year, 
                               interval_value: 521)
      travel_to("2001-01-01")  # Monday
      task.update!(done: true)
      assert_equal Date.new(2001, 5, 21), Task.last.due_date
    end
  end
end
