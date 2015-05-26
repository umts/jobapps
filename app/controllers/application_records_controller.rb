class ApplicationRecordsController < ApplicationController

  def create
    permit_student_access
    params.require :responses
    params.require :position_id
    record = ApplicationRecord.create(position_id: params[:position_id],
                                      responses: params[:responses],
                                      user: @current_user,
                                      reviewed: false)
    redirect_to record #if staff, if not go to the thank you page or something
  end

  def review
    params.require :id
    record = ApplicationRecord.find params[:id]
    if record.update_attribute :reviewed, true
      flash[:message] = 'Application has been marked as reviewed.'
    else flash[:errors] = record.errors.full_messages
    end
    redirect_to staff_dashboard_path
  end

  def show
    permit_student_access
    params.require :id
    @record = ApplicationRecord.find params[:id]
    @interview = @record.interview
  end

end
