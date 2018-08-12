json.extract! task, :id, :title, :done, :due_date, :created_at, :updated_at
json.project task.project
json.url task_url(task, format: :json)
