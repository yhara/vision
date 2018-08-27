require 'ovto'

class MyApp < Ovto::App
  class View < Ovto::Component
    class TaskDetails < Ovto::Component
      def render(state:, focused_task:)
        task = state.editing_task
        id_title = "TaskDetails-title"
        id_due_date = "TaskDetails-due-date" 
        id_project = "TaskDetails-project"
        o '.TaskDetailsContainer' do
          o '.TaskDetails' do
            o 'div' do
              o 'label', {for: id_title}, 'Title:'
              o 'input', id: id_title, type: 'text', value: task.title,
                oninput: ->(e){ actions.edit_task(diff: {title: e.target.value}) }
            end
            o 'div' do
              o 'label', {for: id_due_date}, 'Due date:'
              o 'input', id: id_due_date, type: 'date', value: task.due_date,
                onchange: ->(e){ actions.edit_task(diff: {due_date: e.target.value}) }
            end
            o 'div' do
              o 'label', {for: id_project}, 'Project:'
              o 'select', {
                id: id_project,
                onchange: ->(e){ actions.edit_task(diff: {
                  project_id: e.target.value.empty? ? nil : e.target.value.to_i }) 
                }
              } do
                o 'option', {value: ""}, "---"
                state.projects.each do |project|
                  o 'option', {
                    value: project.id,
                    selected: task.project_id == project.id
                  }, project.title 
                end
              end
            end
            o 'div' do
              o 'input.save-button', type: 'button', value: 'Save', onclick: ->{
                actions.request_update_task(task: task, updates: task.to_h)
                actions.close_task_editor()
              }
              o 'a', {
                href: '#', onclick: ->(e){
                  e.preventDefault()
                  actions.close_task_editor()
                }
              }, 'Close'
            end
          end
        end
      end
    end
  end
end
