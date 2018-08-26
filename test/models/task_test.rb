require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  context 'interval' do
    should 'everyday(=1 day)' do
      task = FactoryBot.create(:task,
                               interval_type: :n_days, 
                               interval_value: 1)
      travel_to("2001-01-01")
      task.update!(done: true)
      assert_equal Date.new(2001, 1, 2), Task.last.due_date
    end

    should 'every 7 days' do
      task = FactoryBot.create(:task,
                               interval_type: :n_days, 
                               interval_value: 7)
      travel_to("2001-01-01")
      task.update!(done: true)
      assert_equal Date.new(2001, 1, 8), Task.last.due_date
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
