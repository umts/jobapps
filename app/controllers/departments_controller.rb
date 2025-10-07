# frozen_string_literal: true

class DepartmentsController < ApplicationController
  before_action :find_department, only: %i[destroy edit update]

  def new; end
  def edit; end

  def create
    @department = Department.new department_parameters
    if @department.save
      flash[:message] = t('.success')
      redirect_to staff_dashboard_path
    else
      show_errors @department
    end
  end

  def update
    if @department.update department_parameters
      flash[:message] = t('.success')
      redirect_to staff_dashboard_path
    else
      show_errors @department
    end
  end

  def destroy
    @department.destroy
    flash[:message] = t('.success')
    redirect_to staff_dashboard_path
  end

  private

  def find_department
    params.require :id
    @department = Department.find params[:id]
  end

  def department_parameters
    params.expect department: [:name]
  end
end
