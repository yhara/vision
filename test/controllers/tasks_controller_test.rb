require 'test_helper'

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_user(users(:one))
    @task = tasks(:one)
  end

  test "should get index" do
    get tasks_url
    assert_response :success
  end

  test "should get new" do
    get new_task_url
    assert_response :success
  end

  test "should create task" do
    assert_difference('Task.count') do
      post tasks_url, params: { task: { done: @task.done, due_date: @task.due_date, title: @task.title } }
    end

    assert_redirected_to task_url(Task.last)
  end

  test "should show task" do
    get task_url(@task)
    assert_response :success
  end

  test "should get edit" do
    get edit_task_url(@task)
    assert_response :success
  end

  context "update" do
    should "update task" do
      patch task_url(@task), params: { task: { done: @task.done, due_date: @task.due_date, title: @task.title } }
      assert_redirected_to task_url(@task)
    end

    should "include next task if any" do
      task = FactoryBot.create(:task, interval_type: 'n_days_after', interval_value: 1)
      patch task_url(task, format: :json), params: {task: {done: true}}
      assert_equal false, JSON.parse(response.body)["next_task"]["done"]
    end

    should "next task is nil if none" do
      task = FactoryBot.create(:task)
      patch task_url(task, format: :json), params: {task: {done: true}}
      assert_nil JSON.parse(response.body)["next_task"]
    end
  end

  test "should destroy task" do
    assert_difference('Task.count', -1) do
      delete task_url(@task)
    end

    assert_redirected_to tasks_url
  end
end
