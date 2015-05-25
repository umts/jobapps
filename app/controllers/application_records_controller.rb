class ApplicationRecordsController < ApplicationController

  def create
    params.require :responses
    params.require :department_id
    record = ApplicationRecord.create(department_id: params[:department_id],
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
    params.require :id
    @record = ApplicationRecord.find params[:id]
    @interview = @record.interview
  end

end
