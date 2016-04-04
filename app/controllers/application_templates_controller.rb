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
    @old_applications = @current_user.try(:old_applications,
                                          @template.position_id)
    @old_data = {}
    if params[:load_id]
      @old_data = ApplicationRecord.find(params[:load_id]).try :questions_hash || nil
    end
  end

  def toggle_active
    @template.toggle! :active
    if @template.active
      show_message :active_application,
                   default: 'The application is now active.'
    else show_message :inactive_application,
                      default: 'The application is now inactive.'
    end
    redirect_to :back
  end

  def toggle_eeo_enabled
    @template.toggle! :eeo_enabled
    if @template.eeo_enabled
      show_message :eeo_enabled,
                   default: 'EEO data requests enabled on this application.'
    else
      show_message :eeo_disabled,
                   default: 'EEO data requests disabled on this application.'
    end
    redirect_to :back
  end

  private

  def find_template
    @template = ApplicationTemplate.friendly.find(params[:id])
  end
end
