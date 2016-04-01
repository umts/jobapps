class ApplicationRecordsController < ApplicationController
  skip_before_action :access_control, only: [:create, :show]
  before_action :find_record, except: [:create,
                                       :csv_export,
                                       :eeo_data,
                                       :past_applications]
  include ApplicationHelper

  def create
    create_user if @current_user.blank?
    data = parse_application_data(params.require :data)
    params.require :position_id
    ApplicationRecord.create(params.permit(:position_id, :ethnicity, :gender)
                             .merge(data: data,
                                    user: @current_user,
                                    reviewed: false))
    show_message :application_receipt,
                 default: 'Your application has been submitted. Thank you!'
    redirect_to student_dashboard_path
  end

  def csv_export
    start_date = parse_american_date(params.require :start_date)
    end_date = parse_american_date(params.require :end_date)
    @records = ApplicationRecord.in_department(given_or_all_department_ids)
                                .between(start_date, end_date)
    render 'csv_export.csv.erb', layout: false
  end

  def eeo_data
    start_date = parse_american_date(params.require :eeo_start_date)
    end_date = parse_american_date(params.require :eeo_end_date)
    @records = ApplicationRecord.eeo_data(start_date,
                                          end_date,
                                          given_or_all_department_ids)
  end

  def past_applications
    # text field tags must be unique to the page, hence records_start_date
    # instead of just start_date
    start_date = parse_american_date(params.require :records_start_date)
    end_date = parse_american_date(params.require :records_end_date)
    @records = ApplicationRecord.in_department(given_or_all_department_ids)
                                .between(start_date, end_date)
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
    user_attributes = params.require(:user).permit(:first_name,
                                                   :last_name,
                                                   :email)
    user_attributes[:spire] = session[:spire]
    user_attributes[:staff] = false
    session[:user_id] = User.create(user_attributes).id
    set_current_user
  end

  def find_record
    params.require :id
    @record = ApplicationRecord.find params[:id]
  end

  def given_or_all_department_ids
    params[:department_ids] || Department.pluck(:id)
  end
end
