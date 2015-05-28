class ApplicationRecordsController < ApplicationController

  before_action :find_record, except: :create

  def create
    permit_student_access
    params.require :responses
    params.require :position_id
    record = ApplicationRecord.create(position_id: params[:position_id],
                                      responses: params[:responses],
                                      user: @current_user,
                                      reviewed: false)
    show_message :application_receipt_confirmation,
       default: 'Your application has been submitted. Thank you!'
    redirect_to student_dashboard_path
  end

  def review
    params.require :accepted
    if params[:accepted] == 'true'
      interview_parameters = params.require(:interview).
                                    permit :location, :scheduled
      interview_parameters.merge! completed: false,
        hired: false, application_record: @record, user: @record.user
      Interview.create! interview_parameters
    else
      staff_note = params.require :staff_note
      @record.update staff_note: staff_note
      #show_message :application_review_confirmation,
        #default: 'Application has been marked as reviewed.'
    end
    @record.update reviewed: true
    redirect_to staff_dashboard_path
  end

  def show
    permit_student_access
    params.require :id
    @record = ApplicationRecord.find params[:id]
    @interview = @record.interview
  end

  private

  def find_record
    params.require :id
    @record = ApplicationRecord.find params[:id]
  end

end
