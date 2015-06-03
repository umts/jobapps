class DepartmentsController < ApplicationController
  before_action :find_department, only: [:destroy, :edit, :update]

  def create
    @department = Department.new department_parameters
    if @department.save
      flash[:message] = "Department #{@department.name} successfully created."
      redirect_to staff_dashboard_path
    else show_errors @department
    end
  end

  def destroy
    @department.destroy
    flash[:message] = "Department #{@department.name} and positions deleted."
    redirect_to staff_dashboard_path
  end

  def edit
  end

  def new
  end

  def update
    if @department.update department_parameters
      flash[:message] = "#{@department.name} has been updated."
      redirect_to staff_dashboard_path
    else show_errors @department
    end
  end

  private

  def find_department
    params.require :id
    @department = Department.find params[:id]
  end

  def department_parameters
    params.require(:department).permit :name
  end
end
