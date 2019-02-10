class TasksController < ApplicationController
  include Pagy::Backend
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def main
    @no_header = true
  end

  # GET /tasks
  # GET /tasks.json
  def index
    query = Task.all
    case params[:done]
    when "0"
      query = query.where(done: false)
    when "1"
      query = query.where(done: true)
    end
    case params[:sort]
    when "updated_at"
      query = query.order(updated_at: :desc)
    when "due_date"
      query = query.order(due_date: :desc)
    end
    @pagy, @tasks = pagy(query)
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(
        :title, :done, :due_date, :project_id, :interval_type, :interval_value
      )
    end
end
