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
    position = Position.find(params.require :position_id)
    template = ApplicationTemplate.create!(position: position, active: true)
    @draft = template.create_draft @current_user
    redirect_to edit_draft_path(@draft)
  end

  def show
  end

  def toggle_active
    @template.toggle!(:active)
    redirect_to :back
  end

  private

  def find_template
    params.require :department
    params.require :position
    @template = ApplicationTemplate.find do |apptem|
      apptem.department.name.casecmp(params[:department]).zero? &&
      apptem.position.name.casecmp(params[:position]).zero?
    end || raise(ActiveRecord::RecordNotFound)
  end
end
