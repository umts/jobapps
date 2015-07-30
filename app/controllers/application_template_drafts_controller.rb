class ApplicationTemplateDraftsController < ApplicationController
  before_action :find_application_template_draft, except: :new

  def destroy
    @draft.destroy
    flash[:message] = 'Your draft has been discarded.'
    redirect_to staff_dashboard_url
  end

  def edit
    @draft.questions << @draft.new_question
  end

  def new
    template = ApplicationTemplate.find(params.require :application_template_id)
    @draft = template.create_draft @current_user
    redirect_to edit_application_template_draft_path(@draft)
  end

  def move_question
    question_number = params.require(:number).to_i
    direction = params.require(:direction).to_sym
    @draft.move_question question_number, direction
    redirect_to edit_application_template_draft_path
  end

  def remove_question
    question_number = params.require(:number).to_i
    @draft.remove_question question_number
    redirect_to edit_application_template_draft_path
  end

  def save_question
    # what do here?
  end

  def update
    params.require(:application_template_draft).permit!
    @draft.update params[:application_template_draft].except(:questions_attributes)
    @draft.update_questions params[:application_template_draft][:questions_attributes]
    case params.require :commit
    when 'Save changes and continue editing'
      redirect_to edit_application_template_draft_path(@draft)
    when 'Preview changes'
      render 'show'
    end
  end

  def update_application_template
    @draft.update_application_template!
    flash[:message] = 'Application has been updated and is now live. ' \
                      'Draft has been discarded.'
    redirect_to application_templates_url
  end

  private

  def find_application_template_draft
    @draft = ApplicationTemplateDraft.includes(:questions)
                                     .find(params.require :id)
  end
end
