json.extract! task,
              :id,
              :title,
              :done,
              :due_date,
              :project_id,
              :interval_type,
              :interval_value,
              :created_at,
              :updated_at
json.next_task do
  if task.next_task
    json.partial! task.next_task
  else
    json.null!
  end
end
json.url task_url(task, format: :json)
