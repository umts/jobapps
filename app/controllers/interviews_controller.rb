class InterviewsController < ApplicationController
  before_action :find, except: :create

  def complete
    if @interview.update completed: true
      flash[:message] = 'Interview marked as completed.'
      #TODO: some kind of API call to UMTS.org.
      #May not want to implement if we're keeping this generic.
      redirect_to staff_dashboard_path
    else
      flash[:errors] = @interview.errors.full_messages
      redirect_to :back
    end
  end
  
  def create
    interview = Interview.create interview_parameters
    if interview
      interview.application_record.update reviewed: true
      flash[:message] = 'Interview has been scheduled and application marked as reviewed.'
      redirect_to staff_dashboard_path
    else
      flash[:errors] = interview.errors.full_messages
      redirect_to :back
    end
  end

  def reschedule
    params.require :scheduled
    params.require :location
    if @interview.update scheduled: params[:scheduled], location: params[:location]
      flash[:message] = 'Interview has been rescheduled.'
      redirect_to staff_dashboard_path
    else
      flash[:errors] = @interview.errors.full_messages
      redirect_to :back
    end
  end

  def show
  end

  private

  def find
    params.require :id
    @interview = Interview.find params[:id]
  end

  def interview_parameters
    params.require(:interview).permit :application_record_id,
                                      :completed,
                                      :hired,
                                      :location
                                      :scheduled
                                      :user_id
  end

end
