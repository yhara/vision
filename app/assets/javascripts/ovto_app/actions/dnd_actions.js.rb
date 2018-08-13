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
        updated_task = task.dup
        drop_target = state.drag_info.drop_target
        updates = nil
        case drop_target.type
        when "due_date"
          date = drop_target.key
          if date != task.due_date
            new_date = (date == DATE_UNSORTED ? nil : date)
            updates = {due_date: new_date}
          end
        when "project"
          project_id = drop_target.key
          if project_id != task.project_id
            updates = {project_id: project_id}
          end
        else raise
        end
        if updates
          updated_task = task.merge(**updates)
          actions.request_update_task(task: task, updates: updates)
        end
        return {
          drag_info: state.drag_info.merge(task_id: nil, drop_target: DropTarget.new, dragover_occurred: false),
          tasks: Task.merge(state.tasks, updated_task)
        }
      end
    end
  end
end
