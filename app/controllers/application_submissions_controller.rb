# frozen_string_literal: true

class ApplicationSubmissionsController < ApplicationController
  skip_before_action :access_control, only: %i[create show]
  before_action :find_record, except: %i[create
                                         csv_export
                                         eeo_data
                                         past_applications]

  def create
    create_user if @current_user.blank?
    data = ApplicationDataParser.new(params.require(:data)).result
    params.require :position_id
    record = ApplicationSubmission.create record_params.merge(data:, user: @current_user, reviewed: false)
    record.email_subscribers applicant: @current_user

    create_unavailability(record) if record.position.application_template.unavailability_enabled?

    show_message :application_receipt,
                 default: 'Your application has been submitted. Thank you!'
    redirect_to student_dashboard_path
  end

  def csv_export
    respond_to :csv
    start_date = Date.parse params[:start_date]
    end_date = Date.parse params[:end_date]
    @records = ApplicationSubmission.in_department(given_or_all_department_ids)
                                    .between(start_date, end_date)
    render layout: false
  end

  def eeo_data
    start_date = Date.parse params[:eeo_start_date]
    end_date = Date.parse params[:eeo_end_date]
    @records = ApplicationSubmission.eeo_data(start_date,
                                              end_date,
                                              given_or_all_department_ids)
  end

  def past_applications
    # text field tags must be unique to the page, hence records_start_date
    # instead of just start_date
    start_date = Date.parse params[:records_start_date]
    end_date = Date.parse params[:records_end_date]
    @records = ApplicationSubmission.in_department(given_or_all_department_ids)
                                    .between(start_date, end_date)
  end

  def review
    @record.update review_params
    if params[:application_submission][:accepted] == 'true'
      @interview = @record.interview || Interview.new(application_submission: @record)
      @interview.update! interview_params
    else
      @record.deny
    end
    show_message :application_review,
                 default: 'Application has been marked as reviewed.'
    redirect_to staff_dashboard_path
  end

  def toggle_saved_for_later
    if @record.update save_for_later_params
      flash[:message] = 'Application successfully updated'
    else
      flash[:errors] = @record.errors.full_messages
    end
    redirect_to staff_dashboard_path
  end

  def show
    deny_access and return unless @current_user == @record.user || @current_user.try(:staff?)

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

  def unreject
    @record.move_to_dashboard
    redirect_to staff_dashboard_path
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
    up = UnavailabilityParser.new(params.require(:unavailability))
    record.create_unavailability(up.result)
  end

  def find_record
    params.require :id
    @record = ApplicationSubmission.find params[:id]
  end

  def given_or_all_department_ids
    params[:department_ids] || Department.pluck(:id)
  end

  def record_params
    params.permit(:position_id, :ethnicity, :gender, :resume)
  end

  def save_for_later_params
    params.require(:application_submission).permit(
      :note_for_later, :mail_note_for_later, :date_for_later, :email_to_notify
    ).tap do |p|
      p[:saved_for_later] = params[:commit] == 'Save for later'
      p[:mail_note_for_later] = p[:mail_note_for_later] == '1'
      p[:date_for_later] = Date.parse p[:date_for_later] if p[:date_for_later].present?
    end
  end

  def interview_params
    interview_parameters = params.require(:interview)
                                 .permit(:location, :scheduled)
    interview_parameters.merge(
      completed: false,
      hired: false,
      application_submission: @record,
      user: @record.user
    )
  end

  def review_params
    parameters = params
                 .require(:application_submission)
                 .permit(:staff_note, :rejection_message, :notify_of_denial)
    parameters[:notify_of_denial] = parameters[:notify_of_denial] == '1'
    parameters.merge(reviewed: true, saved_for_later: false)
  end
end
