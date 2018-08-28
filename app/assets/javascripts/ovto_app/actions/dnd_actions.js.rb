require 'ovto'

class MyApp < Ovto::App
  class Actions < Ovto::Actions
    module DndActions
      def drag_start(state:, task:)
        return {drag_info: state.drag_info.merge(task_id: task.id)}
      end

      def drag_enter(state:, drop_target:)
        return {drag_info: state.drag_info.merge(drop_target: drop_target, dragover_occurred: false)}
      end

      def drag_over(state:)
        return {drag_info: state.drag_info.merge(dragover_occurred: true)}
      end

      def drag_leave(state:)
        if state.drag_info.dragover_occurred
          return {drag_info: state.drag_info.merge(drop_target: DropTarget.new, dragover_occurred: false)}
        end
      end

      def drag_drop(state:)
        task = state.tasks.find{|t| t.id == state.drag_info.task_id}
        drop_target = state.drag_info.drop_target
        updates = nil
        case drop_target.type
        when "due_date"
          date = drop_target.key
          updated_task = task.merge(due_date: date == DATE_UNSORTED ? nil : date)
        when "project"
          project_id = drop_target.key
          updated_task = task.merge(project_id: drop_target.key)
        else
          raise
        end
        if updated_task != task
          actions.request_update_task(task: updated_task)
        end
        return {
          drag_info: state.drag_info.merge(task_id: nil, drop_target: DropTarget.new, dragover_occurred: false),
        }
      end
    end
  end
end
