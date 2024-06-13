# frozen_string_literal: true

class ApplicationTemplatesController < ApplicationController
  skip_before_action :access_control, only: :show
  before_action :find_template, except: :new

  def show
    @old_applications = @current_user.try(:old_applications,
                                          @template)
    @old_data = {}
    return unless params[:load_id]

    @old_data = ApplicationSubmission.find(params[:load_id])
                                     .try :questions_hash || {}
  end

  def new
    position = Position.find(params.require :position_id)
    template = ApplicationTemplate.create!(position:, active: true)
    @draft = template.create_draft @current_user
    redirect_to edit_draft_path(@draft)
  end

  def toggle_active
    # We know it does.
    # rubocop:disable Rails/SkipsModelValidations
    @template.toggle! :active
    # rubocop:enable Rails/SkipsModelValidations
    flash[:message] = t(@template.active ? '.now_active' : '.now_inactive')
    redirect_back fallback_location: application_path(@template)
  end

  def toggle_eeo_enabled
    # We know it does.
    # rubocop:disable Rails/SkipsModelValidations
    @template.toggle! :eeo_enabled
    # rubocop:enable Rails/SkipsModelValidations
    flash[:message] = t(@template.eeo_enabled? ? '.enabled' : '.disabled')
    if @template.draft_belonging_to? @current_user
      draft = @template.draft_belonging_to @current_user
      back_path = edit_draft_path(draft)
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
    flash[:message] = t(@template.unavailability_enabled? ? '.enabled' : '.disabled')
    if @template.draft_belonging_to? @current_user
      draft = @template.draft_belonging_to @current_user
      back_path = edit_draft_path(draft)
    else
      back_path = application_path(@template)
    end
    redirect_back fallback_location: back_path
  end

  def toggle_resume_upload_enabled
    # rubocop:disable Rails/SkipsModelValidations
    @template.toggle! :resume_upload_enabled
    # rubocop:enable Rails/SkipsModelValidations
    flash[:message] = t(@template.resume_upload_enabled? ? '.enabled' : '.disabled')
    if @template.draft_belonging_to? @current_user
      draft = @template.draft_belonging_to @current_user
      back_path = edit_draft_path(draft)
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
