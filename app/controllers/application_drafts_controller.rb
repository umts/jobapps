# frozen_string_literal: true

class ApplicationDraftsController < ApplicationController
  before_action :find_draft, except: :new

  def new
    template = ApplicationTemplate.find params.require(:application_template_id)
    @draft = template.create_draft(Current.user) || template.draft_belonging_to(Current.user)
    redirect_to edit_draft_path(@draft)
  end

  def edit
    @draft.questions << @draft.new_question
  end

  def update
    draft_params = params.expect(draft: [:email, { questions_attributes: [%i[id number prompt data_type required]] }])
    questions = draft_params.require(:questions_attributes).values
    @draft.update email: draft_params[:email]
    @draft.update_questions questions
    case params.require :commit
    when 'Save changes and continue editing'
      redirect_to edit_draft_path(@draft)
    when 'Preview changes'
      render 'show'
    end
  end

  def destroy
    @draft.destroy
    flash[:message] = t('.success')
    redirect_to staff_dashboard_url
  end

  def update_application_template
    @draft.update_application_template!
    flash[:message] = t('.success')
    redirect_to staff_dashboard_url
  end

  private

  def find_draft
    @draft = ApplicationDraft.includes(:questions).find(params.require(:id))
  end
end
