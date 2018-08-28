require 'ovto'

class MyApp < Ovto::App
  class View < Ovto::Component
    class TaskDetails < Ovto::Component
      def render(state:, task:)
        id_title = "TaskDetails-title"
        id_due_date = "TaskDetails-due-date" 
        id_project = "TaskDetails-project"
        o '.TaskDetailsContainer' do
          o '.TaskDetails' do
            o 'div' do
              o 'label', {for: id_title}, 'Title:'
              o 'input', id: id_title, type: 'text', value: task.title
            end
            o 'div' do
              o 'label', {for: id_due_date}, 'Due date:'
              o 'input', id: id_due_date, type: 'date', value: task.due_date
            end
            o 'div' do
              o 'label', {for: id_project}, 'Project:'
              o 'select', id: id_project do
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
                new_project_id_str = `document.querySelector('#'+id_project).value`
                new_project_id = new_project_id_str == "" ? nil : new_project_id_str.to_i
                actions.request_update_task(task: task, updates: {
                  title: `document.querySelector('#'+id_title).value`,
                  due_date: `document.querySelector('#'+id_due_date).value`,
                  project_id: new_project_id,
                })
                actions.hide_task_details()
              }
              o 'a', {
                href: '#', onclick: ->(e){
                  e.preventDefault()
                  actions.hide_task_details()
                }
              }, 'Close'
            end
          end
        end
      end
    end
  end
end
