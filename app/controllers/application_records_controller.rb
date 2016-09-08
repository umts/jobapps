require 'prawn'
class ApplicationRecordsController < ApplicationController
  skip_before_action :access_control, only: [:create, :show]
  before_action :find_record, except: [:create,
                                       :csv_export,
                                       :eeo_data,
                                       :past_applications,
                                       :saved_applications]
  include ApplicationHelper

  def create
    create_user if @current_user.blank?
    data = parse_application_data(params.require :data)
    params.require :position_id
    record = ApplicationRecord.create(record_params.merge(data: data,
                                                          user: @current_user,
                                                          reviewed: false))
    record.email_subscribers applicant: @current_user

    if record.position.application_template.unavailability_enabled?
      create_unavailability(record)
    end

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

  def saved_applications
    @saved = ApplicationRecord.where(saved_for_later: true)
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
    @record.update saved_for_later: false
    redirect_to staff_dashboard_path
  end

  def save_for_later
    date = if params[:date_for_later].present?
             Date.strptime(params[:date_for_later], '%m/%d/%Y')
           else ''
           end
    @record.update_attributes(saved_for_later: true,
                              note_for_later: params[:note_for_later],
                              date_for_later: date)
    redirect_to staff_dashboard_path
    flash[:message] = 'Application saved for later'
  end

  def unsave_for_later
    @record.update_attributes(saved_for_later: false,
                              note_for_later: nil,
                              date_for_later: nil)
    redirect_to staff_dashboard_path
    flash[:message] = 'Application moved back to dashboard'
  end

  def show
    deny_access && return if @current_user.student? &&
                             @current_user != @record.user
    @interview = @record.interview
    respond_to do |format|
      format.html
      format.pdf do
        pdf = PrintRecordPdf.new(@record)
        send_data pdf.render, filename: "#{@record.user.full_name}.pdf",
                              type: 'application/pdf',
                              disposition: :inline
      end
    end
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

  def create_unavailability(record)
    unavail_params = parse_unavailability(params.require :unavailability)
                     .merge application_record: record
    Unavailability.create unavail_params
  end

  def find_record
    params.require :id
    @record = ApplicationRecord.find params[:id]
  end

  def given_or_all_department_ids
    params[:department_ids] || Department.pluck(:id)
  end

  def record_params
    params.permit(:position_id, :ethnicity, :gender)
  end
end
