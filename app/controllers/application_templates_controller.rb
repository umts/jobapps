class ApplicationTemplatesController < ApplicationController
  skip_before_action :access_control, only: [:bus, :show]
  before_action :find_template, except: [:bus, :new]

  def bus
    department = Department.find_by name: 'Bus'
    position = Position.find_by department: department, name: 'Operator'
    @template = ApplicationTemplate.find_by position: position
    render 'show'
  end

  def new
    params.require :position_id
    template = ApplicationTemplate.create position_id: params[:position_id]
    redirect_to edit_application_template_path(template)
  end

  def edit
  end

  def show
  end

  private

  def find_template
    params.require :id
    @template = ApplicationTemplate.find params[:id]
  end
end
