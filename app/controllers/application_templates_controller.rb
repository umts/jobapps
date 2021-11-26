# frozen_string_literal: true

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
                                          @template)
    @old_data = {}
    return unless params[:load_id]

    @old_data = ApplicationSubmission.find(params[:load_id])
                                     .try :questions_hash || {}
  end

  def toggle_active
    # We know it does.
    # rubocop:disable Rails/SkipsModelValidations
    @template.toggle! :active
    # rubocop:enable Rails/SkipsModelValidations
    if @template.active
      show_message :active_application,
                   default: 'The application is now active.'
    else show_message :inactive_application,
                      default: 'The application is now inactive.'
    end
    redirect_back fallback_location: application_path(@template)
  end

  def toggle_eeo_enabled
    # We know it does.
    # rubocop:disable Rails/SkipsModelValidations
    @template.toggle! :eeo_enabled
    # rubocop:enable Rails/SkipsModelValidations
    if @template.eeo_enabled?
      show_message :eeo_enabled,
                   default: 'EEO data requests enabled on this application.'
    else
      show_message :eeo_disabled,
                   default: 'EEO data requests disabled on this application.'
    end
    if @template.draft_belonging_to? @current_user
      back_path = edit_draft_path(@template.draft)
    else
      back_path = application_path(@template)
    end
    redirect_back fallback_location: back_path
  end

  def toggle_unavailability_enabled
    # We know it does.
    # rubocop:disable Rails/SkipsModelValidations
    @template.toggle! :unavailability_enabled
    # rubocop:enable Rails/SkipsModelValidations
    if @template.unavailability_enabled?
      show_message :unavailability_enabled,
                   default: 'Unavailability requests enabled on
                            this application.'
    else
      show_message :unavailability_disabled,
                   default: 'Unavailability requests disabled on
                            this application.'
    end
    if @template.draft_belonging_to? @current_user
      back_path = edit_draft_path(@template.draft)
    else
      back_path = application_path(@template)
    end
    redirect_back fallback_location: back_path
  end

  def toggle_resume_upload_enabled
    # rubocop:disable Rails/SkipsModelValidations
    @template.toggle! :resume_upload_enabled
    # rubocop:enable Rails/SkipsModelValidations
    if @template.resume_upload_enabled?
      show_message :unavailability_enabled,
                   default: 'Resume uploads enabled on
                            this application.'
    else
      show_message :unavailability_disabled,
                   default: 'Resume uploads disabled on
                            this application.'
    end
    if @template.draft_belonging_to? @current_user
      back_path = edit_draft_path(@template.draft)
    else
      back_path = application_path(@template)
    end
    redirect_back fallback_location: back_path
  end

  private

  def find_template
    @template = ApplicationTemplate.friendly.find(params[:id])
  end
end
