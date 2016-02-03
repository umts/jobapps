class ApplicationTemplatesController < ApplicationController
  skip_before_action :access_control, only: :show
  before_action :find_template, except: :new

  def new
    position = Position.find(params.require :position_id)
    template = ApplicationTemplate.create!(position: position, active: true)
    @draft = template.create_draft @current_user
    redirect_to edit_draft_path(@draft)
  end

  def show
  end

  def toggle_active
    @template.toggle! :active
    redirect_to :back
  end

  private

  def find_template
    dept      = Department.by_name params.require(:department)
    position  = Position.by_name_and_department params.require(:position), dept
    @template = position.application_template
  end
end
