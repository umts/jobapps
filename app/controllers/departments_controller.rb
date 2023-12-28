# frozen_string_literal: true

class DepartmentsController < ApplicationController
  before_action :find_department, only: %i[destroy edit update]

  def create
    @department = Department.new department_parameters
    if @department.save
      show_message :department_create,
                   default: 'Department has been created.'
      redirect_to staff_dashboard_path
    else
      show_errors @department
    end
  end

  def destroy
    @department.destroy
    show_message :department_destroy,
                 default: 'Department has been deleted.'
    redirect_to staff_dashboard_path
  end

  def edit; end

  def new; end

  def update
    if @department.update department_parameters
      show_message :department_update,
                   default: 'Department has been updated.'
      redirect_to staff_dashboard_path
    else
      show_errors @department
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
