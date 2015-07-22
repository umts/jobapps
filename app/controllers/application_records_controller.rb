class ApplicationRecordsController < ApplicationController
  skip_before_action :access_control, only: [:create, :show]
  before_action :find_record, except: :create

  def create
    create_user if @current_user.blank?
    params.require :responses
    params.require :position_id
    ApplicationRecord.create(position_id: params[:position_id],
                             responses: params[:responses],
                             user: @current_user,
                             reviewed: false)
    show_message :application_receipt,
                 default: 'Your application has been submitted. Thank you!'
    redirect_to student_dashboard_path
  end

  def review
    if params.require(:accepted) == 'true'
      interview_parameters = params.require(:interview)
                             .permit(:location, :scheduled)
      interview_parameters.merge! completed: false,
                                  hired: false,
                                  application_record: @record,
                                  user: @record.user
      Interview.create! interview_parameters
    else
      @record.update staff_note: params.require(:staff_note)
      if configured_value [:on_application_denial, :notify_applicant],
                          default: true
        JobappsMailer.application_denial(@record).deliver_now
      end
    end
    show_message :application_review,
                 default: 'Application has been marked as reviewed.'
    @record.update reviewed: true
    redirect_to staff_dashboard_path
  end

  def show
    deny_access if @current_user.student? && @current_user != @record.user
    @interview = @record.interview
  end

  private

  def create_user
    user_attributes = params.require(:user).permit!
    user_attributes.merge! spire: session[:spire], staff: false
    session[:user_id] = User.create(user_attributes).id
    set_current_user
  end

  def find_record
    params.require :id
    @record = ApplicationRecord.find params[:id]
  end
end
