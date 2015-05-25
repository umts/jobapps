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
    params.require(:interview).permit!
    interview = Interview.create params[:interview]
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
    if @interview.update scheduled: params[:scheduled]
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

end
