class ApplicationRecordsController < ApplicationController
  skip_before_action :access_control, only: [:create, :show]
  before_action :find_record, except: [:create, :csv_export]
  include ApplicationHelper

  def create
    create_user if @current_user.blank?
    @data = parse_application_data(params.require :responses)
    params.require :position_id
    ApplicationRecord.create(position_id: params[:position_id],
                             responses: @data,
                             user: @current_user,
                             reviewed: false)
    show_message :application_receipt,
                 default: 'Your application has been submitted. Thank you!'
    redirect_to student_dashboard_path
  end

  def csv_export
    start_date = parse_american_date(params.require :start_date)
    end_date = parse_american_date(params.require :end_date)
    @records = ApplicationRecord.between(start_date, end_date)
  end

  def review
    if params.require(:accepted) == 'true'
      interview_parameters = params.require(:interview)
      interview_parameters.require :location
      interview_parameters.require :scheduled
      interview_parameters = interview_parameters.symbolize_keys
      interview_parameters.merge! completed: false,
                                  hired: false,
                                  application_record: @record,
                                  user: @record.user
      Interview.create! interview_parameters
    else @record.deny_with params.require(:staff_note)
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
