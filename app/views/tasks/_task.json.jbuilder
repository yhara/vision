json.extract! task, :id, :title, :done, :due_date, :project_id, :interval_type, :interval_value, :created_at, :updated_at
json.url task_url(task, format: :json)
