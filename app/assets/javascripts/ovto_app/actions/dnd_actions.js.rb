require 'ovto'

class MyApp < Ovto::App
  class Actions < Ovto::Actions
    module DndActions
      def drag_start(state:, task:)
        return {drag_info: state.drag_info.merge(task_id: task.id)}
      end

      def drag_enter(state:, target_date:)
        return {drag_info: state.drag_info.merge(target_date: target_date, dragover_occurred: false)}
      end

      def drag_over(state:, target_date:)
        return {drag_info: state.drag_info.merge(dragover_occurred: true)}
      end

      def drag_leave(state:, target_date:)
        if state.drag_info.dragover_occurred
          return {drag_info: state.drag_info.merge(target_date: nil, dragover_occurred: false)}
        end
      end

      def drag_drop(state:)
        task = state.tasks.find{|t| t.id == state.drag_info.task_id}
        date = state.drag_info.target_date 
        updated_task = task.dup
        if date && date != task.due_date
          new_date = (date == DATE_UNSORTED ? nil : date)
          updated_task = task.merge(due_date: new_date)
          actions.request_update_task(task: task, updates: {due_date: new_date})
        end
        return {
          drag_info: state.drag_info.merge(task_id: nil, target_date: nil, dragover_occurred: false),
          tasks: Task.merge(state.tasks, updated_task)
        }
      end
    end
  end
end
