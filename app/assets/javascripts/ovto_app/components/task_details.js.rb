require 'ovto'

class MyApp < Ovto::App
  module Components
    class TaskDetails < Ovto::Component
      def render(state:, focused_task:)
        task = state.editing_task
        id_title = "TaskDetails-title"
        id_due_date = "TaskDetails-due-date" 
        id_project = "TaskDetails-project"
        id_done = "TaskDetails-done"
        o '.TaskDetailsContainer' do
          o '.TaskDetails' do
            o 'div' do
              o 'label', {for: id_title}, 'Title:'
              o 'input', {
                id: id_title,
                type: 'text',
                value: task.title,
                oninput: ->(e){ actions.edit_task(diff: {title: e.target.value}) },
                onkeydown: ->(e){ submit(task) if e.key == "Enter" },
              }
            end

            o 'div' do
              o 'label', {for: id_due_date}, 'Due date:'
              o 'input', {
                id: id_due_date,
                type: 'date',
                value: task.due_date,
                onchange: ->(e){ actions.edit_task(diff: {due_date: e.target.value}) }
              }
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

            o TaskIntervalInput, task: task

            o 'div' do
              o 'label', {for: id_done}, 'Done:'
              o 'input', {
                id: id_done,
                type: 'checkbox', 
                onchange: ->(e) { actions.edit_task(diff: {done: e.target.checked}) }
              }
            end

            o 'div' do
              o 'input.save-button', type: 'button', value: 'Save', onclick: ->{
                submit(task)
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

      def submit(task)
        actions.request_update_task(task: task)
        actions.close_task_editor()
      end

      class TaskIntervalInput < Ovto::Component
        def render(task:)
          o '.TaskIntervalInput' do
            o TaskIntervalTypeInput, task: task
            o TaskIntervalValueInput, task: task
          end
        end

        class TaskIntervalTypeInput < Ovto::Component
          def render(task:)
            id_interval_type = "TaskDetails-interval-type"
            o '.TaskIntervalTypeInput' do
              o 'label', {for: id_interval_type}, 'Interval:'
              o 'select', {
                id: id_interval_type,
                onchange: ->(e){
                  actions.edit_task(diff: {
                    interval_type: (e.target.value.empty? ? nil : e.target.value),
                    interval_value: nil,
                  })
                }
              } do
                o 'option', {selected: (task.interval_type == nil), value: ""}, "None"
                o 'option', {selected: (task.interval_type == "every_n_days"), value: "every_n_days"}, "Every N days"
                o 'option', {selected: (task.interval_type == "n_days_after"), value: "n_days_after"}, "N days after"
                o 'option', {selected: (task.interval_type == "day_of_week"), value: "day_of_week"}, "Day of week"
                o 'option', {selected: (task.interval_type == "day_of_month"), value: "day_of_month"}, "Day of month"
                o 'option', {selected: (task.interval_type == "day_of_year"), value: "day_of_year"}, "Day of year"
              end
            end
          end
        end

        class TaskIntervalValueInput < Ovto::Component
          def render(task:)
            id_interval_value = "TaskDetails-interval-value"
            o '.TaskIntervalValueInput' do
              case task.interval_type
              when nil
                ""
              when :every_n_days, :n_days_after
                o 'input', id: id_interval_value, type: 'number', value: task.interval_value, min: 1,
                  onchange: ->(e){ actions.edit_task(diff: {interval_value: e.target.value.to_i}) }
              when :day_of_week
                o 'select', {
                  id: id_interval_value,
                  onchange: ->(e){ actions.edit_task(diff: {interval_value: e.target.value.to_i}) }
                } do
                  o 'option', {value: "0", selected: task.interval_value == 0}, "Sun"
                  o 'option', {value: "1", selected: task.interval_value == 1}, "Mon"
                  o 'option', {value: "2", selected: task.interval_value == 2}, "Tue"
                  o 'option', {value: "3", selected: task.interval_value == 3}, "Wed"
                  o 'option', {value: "4", selected: task.interval_value == 4}, "Thu"
                  o 'option', {value: "5", selected: task.interval_value == 5}, "Fri"
                  o 'option', {value: "6", selected: task.interval_value == 6}, "Sat"
                end
              when :day_of_month
                o 'input', id: id_interval_value, type: 'number', value: task.interval_value, min: 1, max: 31,
                  onchange: ->(e){ actions.edit_task(diff: {interval_value: e.target.value}) }
              when :day_of_year
                interval_value = task.interval_value || 101
                m, d = interval_value.divmod(100)
                o 'text', "XXXX-"
                o 'input', id: id_interval_value, type: 'number', value: m, min: 1, max: 12,
                  onchange: ->(e){ actions.edit_task(diff: {interval_value: e.target.value.to_i * 100 + d }) }
                o 'text', "-"
                o 'input', type: 'number', value: d, min: 1, max: 31,
                  onchange: ->(e){ actions.edit_task(diff: {interval_value: m * 100 + e.target.value.to_i}) }
              else
                raise "Unexpected interval_type"
              end
            end
          end
        end
      end
    end
  end
end
